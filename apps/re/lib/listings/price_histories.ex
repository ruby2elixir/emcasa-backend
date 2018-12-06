defmodule Re.Listings.PriceHistories do
  @moduledoc """
  Context for handling listing's price history
  """
  import Ecto.Query

  alias Re.{
    Listings.PriceHistory,
    Repo
  }

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def insert(listing, price) do
    %PriceHistory{}
    |> PriceHistory.changeset(%{price: price, listing_id: listing.id})
    |> Repo.insert()
  end

  def query(query, args) do
    args
    |> Enum.reduce(query, &build_query/2)
    |> order_by([ph], desc: ph.inserted_at)
  end

  defp build_query({:datetime, datetime}, query),
    do: where(query, [ph], ph.inserted_at > ^datetime)

  defp build_query({:current_price, price}, query), do: where(query, [ph], ph.price > ^price)
  defp build_query(_, query), do: query
end
