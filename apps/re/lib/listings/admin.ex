defmodule Re.Listings.Admin do
  @moduledoc """
  Module for keeping administrative functions
  """

  alias Re.{
    Listings.Filters,
    Listing,
    Listings.Queries,
    Repo
  }

  def listings(params) do
    pagination = Map.get(params, :pagination, %{})
    filters = Map.get(params, :filters, %{})

    Listing
    |> Queries.order_by(params)
    |> Filters.apply(filters)
    |> Repo.paginate(pagination)
  end
end
