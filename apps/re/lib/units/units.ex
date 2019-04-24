defmodule Re.Units do
  @moduledoc """
  Context module for unit. A unit represents realty/real estate properties,
  for a listing. A listing can have one or more units.
  """
  @behaviour Bodyguard.Policy

  alias Ecto.Changeset

  alias Re.{
    PubSub,
    Repo,
    Unit,
    Units.Queries
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.Unit

    Unit
    |> Queries.by_listing(listing_id)
    |> Queries.active()
    |> Repo.all()
  end

  def get(uuid), do: do_get(Unit, uuid)

  defp do_get(query, uuid) do
    case Repo.get(query, uuid) do
      nil -> {:error, :not_found}
      unit -> {:ok, unit}
    end
  end

  def insert(params, development, listing) do
    %Unit{}
    |> Changeset.change(development_uuid: development.uuid)
    |> Changeset.change(listing_id: listing.id)
    |> Unit.changeset(params)
    |> Repo.insert()
    |> publish_new()
  end

  def update(unit, params, development, listing) do
    changeset =
      unit
      |> Changeset.change(development_uuid: development.uuid)
      |> Changeset.change(listing_id: listing.id)
      |> Unit.changeset(params)

    changeset
    |> Repo.update()
    |> publish_update(changeset)
  end

  defp publish_new(result), do: PubSub.publish_new(result, "new_unit")

  defp publish_update(result, changeset),
    do: PubSub.publish_update(result, changeset, "update_unit")
end
