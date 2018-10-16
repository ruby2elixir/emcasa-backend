defmodule Re.Statistics.ListingVisualizations do
  @moduledoc """
  Context for visualizations stats
  """

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.Statistics.ListingVisualization
end
