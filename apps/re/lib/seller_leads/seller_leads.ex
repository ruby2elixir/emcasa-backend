defmodule Re.SellerLeads do
  @moduledoc """
  Context boundary to Seller Leads
  """

  alias Re.{
    SellerLeads.SiteLead,
    Repo
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def create_site(params) do
    %SiteLead{}
    |> SiteLead.changeset(params)
    |> Repo.insert()
  end
end
