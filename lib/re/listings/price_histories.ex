defmodule Re.Listings.PriceHistories do

  import Ecto.Query

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(query, args) do
    query
    |> order_by([ph], desc: ph.inserted_at)
    |> price_change_since(args)
  end

  defp price_change_since(query, %{datetime: datetime}), do: where(query, [ph], ph.inserted_at > ^datetime)
  defp price_change_since(query, _), do: query
end
