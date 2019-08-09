defmodule Re.SellerLeads do
  @moduledoc """
  Context boundary to Seller Leads
  """
  require Ecto.Query

  alias Re.{
    PubSub,
    Repo,
    SellerLead,
    SellerLeads.Facebook,
    SellerLeads.Site
  }

  alias Ecto.Query

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def create_site(params) do
    %Site{}
    |> Site.changeset(params)
    |> Repo.insert()
    |> PubSub.publish_new("new_site_seller_lead")
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
end
