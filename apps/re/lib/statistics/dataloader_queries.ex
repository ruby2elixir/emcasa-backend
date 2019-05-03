defmodule Re.Statistics.DataloaderQueries do
  @moduledoc """
  Module for grouping tags queries
  """
  import Ecto.Query

  def run_batch(_, query, :count, listings, repo_opts) do
    listing_ids = Enum.map(listings, & &1.id)
    default_count = 0

    result =
      query
      |> where([p], p.listing_id in ^listing_ids)
      |> group_by([p], p.listing_id)
      |> select([p], {p.listing_id, count("*")})
      |> Re.Repo.all(repo_opts)
      |> Map.new()

    for %{id: id} <- listings do
      Map.get(result, id, default_count)
    end
  end

  def run_batch(queryable, query, col, inputs, repo_opts) do
    Dataloader.Ecto.run_batch(Re.Repo, queryable, query, col, inputs, repo_opts)
  end
end
