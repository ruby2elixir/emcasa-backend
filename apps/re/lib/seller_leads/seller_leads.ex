defmodule Re.SellerLeads do
  @moduledoc """
  Context boundary to Seller Leads
  """

  alias Re.{
    SellerLeads.SiteLead,
    Repo
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def data(params), do: Dataloader.Ecto.new(Repo, query: &query/2, default_params: params)

  def query(query, _args), do: query

  def create_site(params) do
    %SiteLead{}
    |> SiteLead.changeset(params)
    |> Repo.insert()
  end
end
