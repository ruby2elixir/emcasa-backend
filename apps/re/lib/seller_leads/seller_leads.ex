defmodule Re.SellerLeads do
  @moduledoc """
  Context boundary to Seller Leads
  """
  require Ecto.Query

  alias Re.{
    PubSub,
    Repo,
    OwnerContacts,
    OwnerContact,
    SellerLead,
    SellerLeads.Facebook,
    SellerLeads.Site,
    SellerLeads.Broker
  }

  alias Ecto.{
    Changeset,
    Query
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def create_site(params) do
    %Site{}
    |> Site.changeset(params)
    |> Repo.insert()
    |> PubSub.publish_new("new_site_seller_lead")
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
    check_attribute_duplicated(address, complement, :seller_leads) ||
      check_attribute_duplicated(address, complement, :listings)
  end

  defp check_attribute_duplicated(address, complement, attribute_to_fetch) do
    normalized_complement = normalize_complement(complement)

    address
    |> Repo.preload(attribute_to_fetch)
    |> Map.get(attribute_to_fetch)
    |> Enum.any?(fn attribute ->
      normalize_complement(attribute.complement) == normalized_complement
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
end
