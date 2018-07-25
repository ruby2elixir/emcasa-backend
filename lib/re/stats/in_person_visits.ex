defmodule Re.Stats.InPersonVisits do
  @moduledoc """
  Context for in-person visit stats
  """

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.Stats.InPersonVisit
end
