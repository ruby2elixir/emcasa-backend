defmodule Re.Developments do
  @moduledoc """
  Context for developments.
  """
  @behaviour Bodyguard.Policy

  require Ecto.Query
  import Ecto.Query

  alias Re.{
    Listing,
    Development,
    Developments.Queries,
    Repo
  }

  alias Ecto.Changeset

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.Development

  def all do
    Re.Development
    |> Re.Repo.all()
  end

  def get(uuid), do: do_get(Development, uuid)

  def get_by_orulo_id(orulo_id) do
    case Repo.get_by(Development, orulo_id: orulo_id) do
      nil -> {:error, :not_found}
      development -> {:ok, development}
    end
  end

  def get_typologies(uuid) do
    from(
      l in Listing,
      select: %{
        area: l.area,
        rooms: l.rooms,
        max_price: max(l.price),
        min_price: min(l.price),
        unit_count: count(l.id)
      },
      where: l.development_uuid == ^uuid,
      group_by: [l.area, l.rooms]
    )
    |> Repo.all
  end

  def get_preloaded(uuid, preload),
    do: do_get(Queries.preload_relations(Development, preload), uuid)

  defp do_get(query, uuid) do
    case Repo.get(query, uuid) do
      nil -> {:error, :not_found}
      development -> {:ok, development}
    end
  end

  def insert(params, address), do: do_insert(params, address)

  defp do_insert(params, address) do
    %Re.Development{}
    |> Changeset.change(address_id: address.id)
    |> Development.changeset(params)
    |> Repo.insert()
  end

  def preload(development, preload), do: Re.Repo.preload(development, preload)

  def update(development, params, address) do
    development
    |> Changeset.change(address_id: address.id)
    |> Development.changeset(params)
    |> Repo.update()
  end
end
