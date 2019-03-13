defmodule Re.Units do
  @moduledoc """
  Context module for unit
  """

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.Unit
end
