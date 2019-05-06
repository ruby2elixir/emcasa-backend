defmodule Re.SellerLeads do
  @moduledoc """
  Context boundary to Seller Leads
  """

  alias Re.{
    PubSub,
    Repo,
    SellerLeads.Site
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def create_site(params) do
    %Site{}
    |> Site.changeset(params)
    |> Repo.insert()
    |> PubSub.publish_new("new_site_seller_lead")
  end
end
