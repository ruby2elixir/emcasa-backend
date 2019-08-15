defmodule Re.SellerLeads do
  @moduledoc """
  Context boundary to Seller Leads
  """
  require Ecto.Query

  alias Re.{
    Repo,
    OwnerContacts,
    OwnerContact,
    SellerLead,
    SellerLeads.Facebook,
    SellerLeads.JobQueue,
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

  def duplicated?(address, complement) do
    address
    |> Repo.preload(:seller_leads)
    |> Map.get(:seller_leads)
    |> Enum.any?(fn seller_lead ->
      normalize_complement(seller_lead.complement) == normalize_complement(complement)
    end)
  end

  @number_group_regex ~r/(\d)*/

  defp normalize_complement(nil), do: nil

  defp normalize_complement(complement) do
    @number_group_regex
    |> Regex.scan(complement)
    |> Enum.map(fn list -> List.first(list) end)
    |> Enum.filter(fn result -> String.length(result) >= 1 end)
    |> Enum.sort()
    |> Enum.join("")
  end

  defp return_insertion({:ok, %{insert_site_seller_lead: request}}), do: {:ok, request}

  defp return_insertion(error), do: error
end
