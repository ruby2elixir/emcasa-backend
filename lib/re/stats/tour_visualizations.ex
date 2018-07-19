defmodule Re.Stats.TourVisualizations do
  @moduledoc """
  Context for 3D tour visualizations stats
  """

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.Stats.TourVisualization

end
