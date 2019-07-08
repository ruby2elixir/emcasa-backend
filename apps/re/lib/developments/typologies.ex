defmodule Re.Developments.Typologies do
  @moduledoc """
  Context for handling development typologies
  """

  alias Re.{
    Development,
    Developments,
    Repo
  }

  def data(params),
    do: Dataloader.Ecto.new(Re.Repo, run_batch: &run_batch/5, default_params: params)

  def run_batch(Development, _query, col, development_uuids, _repo_opts) do
    Developments.Listings.typologies(development_uuids)
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
