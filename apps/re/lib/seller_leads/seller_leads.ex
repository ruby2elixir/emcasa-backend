defmodule Re.SellerLeads do
  @moduledoc """
  Context boundary to Seller Leads
  """
  require Ecto.Query

  alias Re.{
    Addresses,
    OwnerContacts,
    OwnerContact,
    PriceSuggestions,
    PubSub,
    Repo,
    SellerLead,
    SellerLeads.Facebook,
    SellerLeads.JobQueue,
    SellerLeads.NotifyWhenCovered,
    SellerLeads.Site,
    SellerLeads.Broker
  }

  alias Ecto.{
    Changeset,
    Multi,
    Query
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def create_site(params) do
    changeset = Site.changeset(%Site{}, params)

    uuid = Changeset.get_field(changeset, :uuid)

    Ecto.Multi.new()
    |> Multi.insert(:insert_site_seller_lead, changeset)
    |> JobQueue.enqueue(:seller_lead_job, %{
      "type" => "process_site_seller_lead",
      "uuid" => uuid
    })
    |> Repo.transaction()
    |> return_insertion()
  end

  def create_broker(params) do
    property_owner_param = Map.get(params, :owner)

    property_owner =
      %OwnerContact{}
      |> OwnerContact.changeset(property_owner_param)
      |> handle_property_owner()

    case property_owner do
      {:error, cause} -> {:error, cause}
      {:ok, owner} -> handle_create_broker(owner, params)
    end
  end

  def create_price_suggestion(_params, nil), do: {:error, :bad_request}

  def create_price_suggestion(params, user) do
    with {:ok, address} <- Addresses.insert_or_update(params.address) do
      params
      |> Map.put(:address_id, address.id)
      |> Map.put(:user_id, user.id)
      |> PriceSuggestions.create_request()
      |> PubSub.publish_new("new_price_suggestion_request")
    end
  end

  def create_out_of_coverage(params) do
    %NotifyWhenCovered{}
    |> NotifyWhenCovered.changeset(params)
    |> Repo.insert()
    |> PubSub.publish_new("notify_when_covered")
  end

  defp handle_create_broker(owner, params) do
    attrs =
      params
      |> Map.merge(%{owner_uuid: owner.uuid})

    %Broker{}
    |> Broker.changeset(attrs)
    |> Repo.insert()
  end

  defp handle_property_owner(property_owner_changeset) do
    phone = Changeset.get_field(property_owner_changeset, :phone)

    case OwnerContacts.get_by_phone(phone) do
      {:error, _} -> Repo.insert_or_update(property_owner_changeset)
      {_, owner} -> {:ok, owner}
    end
  end

  def create(%{"source" => "facebook_seller"} = payload) do
    %Facebook{}
    |> Facebook.changeset(payload)
    |> Repo.insert()
  end

  def get_preloaded(uuid, preloads) do
    SellerLead
    |> Query.preload(^preloads)
    |> do_get(uuid)
  end

  defp do_get(query, uuid) do
    case Repo.get(query, uuid) do
      nil -> {:error, :not_found}
      seller_lead -> {:ok, seller_lead}
    end
  end

  defp return_insertion({:ok, %{insert_site_seller_lead: request}}), do: {:ok, request}

  defp return_insertion(error), do: error
end
