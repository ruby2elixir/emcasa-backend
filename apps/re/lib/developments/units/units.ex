defmodule Re.Units do
  @moduledoc """
  Context module for unit. A unit represents realty/real estate properties,
  for a listing. A listing can have one or more units.
  """
  @behaviour Bodyguard.Policy

  require Logger

  alias Ecto.{
    Changeset,
    Multi
  }

  alias Re.{
    Developments.JobQueue,
    Repo,
    Unit,
    Units.Queries
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.Unit

  def get_by_listing(listing_id) do
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

  def insert(params, development) do
    %Unit{}
    |> Changeset.change(development_uuid: development.uuid)
    |> Unit.changeset(params)
    |> do_new_unit()
  end

  defp do_new_unit(changeset) do
    case changeset do
      %{valid?: true} = changeset ->
        uuid = Changeset.get_field(changeset, :uuid)

        Multi.new()
        |> JobQueue.enqueue(:units_job, %{"type" => "new_unit", "uuid" => uuid})
        |> Multi.insert(:add_unit, changeset)
        |> Repo.transaction()

      %{errors: errors} = changeset ->
        Logger.warn("Invalid payload from new_unit. Errors: #{Kernel.inspect(errors)}")

        {:error, changeset}
    end
  end

  def update(unit, params, development) do
    changeset =
      unit
      |> Changeset.change(development_uuid: development.uuid)
      # |> Changeset.change(listing_id: listing.id)
      |> Unit.changeset(params)

    changeset
    |> Repo.update()
  end
end
