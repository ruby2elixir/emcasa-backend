defmodule Re.Units do
  @moduledoc """
  Context module for unit. A unit represents realty/real estate properties,
  for a listing. A listing can have one or more units.
  """

  alias Ecto.Changeset

  alias Re.{
    Repo,
    Unit
  }

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.Unit

  def insert(params, development) do
    %Unit{}
    |> Changeset.change(development_uuid: development.uuid)
    |> Unit.changeset(params)
    |> Repo.insert()
  end
end
