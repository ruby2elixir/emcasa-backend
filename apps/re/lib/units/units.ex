defmodule Re.Units do
  @moduledoc """
  Context module for unit. A unit represents realty/real estate properties,
  for a listing. A listing can have one or more units.
  """

  alias Re.{
    Repo,
    Unit
  }

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.Unit

  def insert(params, user) do
    %Unit{}
    |> Unit.changeset(params)
    |> Repo.insert()
  end
end
