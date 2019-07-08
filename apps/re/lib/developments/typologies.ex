defmodule Re.Developments.Typologies do
  @moduledoc """
  Context for handling development typologies
  """
  import Ecto.Query

  alias Re.{
    Listing,
    Development,
    Repo
  }

  def data(params), do: Dataloader.Ecto.new(Re.Repo, run_batch: &run_batch/5, default_params: params)

  def run_batch(Development, _query, col, development_uuids, _repo_opts) do
    Listing
    |> select([l], %{
      area: l.area,
      rooms: l.rooms,
      max_price: max(l.price),
      min_price: min(l.price),
      unit_count: count(l.id),
      development_uuid: l.development_uuid
    })
    |> group_by([l], [l.area, l.rooms, l.development_uuid])
    |> where([l], l.development_uuid in ^development_uuids and l.status == "active")
    |> Repo.all
    |> Enum.reduce(%{}, fn typology, map ->
      Map.update(
        map,
        typology.development_uuid,
        [typology],
        &(&1 ++ [typology])
      )
    end)
    |> Enum.map(fn {uuid, typologies} ->
      %{col => uuid, typologies: typologies}
    end)
  end
end
