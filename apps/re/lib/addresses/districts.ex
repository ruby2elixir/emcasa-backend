defmodule Re.Districts do
  @moduledoc """
  Context for handling districts
  """

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(query, _args), do: query
end
