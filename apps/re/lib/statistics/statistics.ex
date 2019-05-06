defmodule Re.Statistics do
  @moduledoc """
  Context for statistics
  """

  alias Re.Statistics.DataloaderQueries

  def data(_params), do: Dataloader.Ecto.new(Re.Repo, run_batch: &run_batch/5)

  def run_batch(queryable, query, col, inputs, repo_opts),
    do: DataloaderQueries.run_batch(queryable, query, col, inputs, repo_opts)
end
