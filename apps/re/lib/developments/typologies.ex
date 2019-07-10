defmodule Re.Developments.Typologies do
  @moduledoc """
  Context for handling development typologies
  """

  alias Re.{
    Development,
    Developments
  }

  def data(params),
    do: Dataloader.Ecto.new(Re.Repo, run_batch: &run_batch/5, default_params: params)

  def run_batch(Development, _query, col, development_uuids, _repo_opts) do
    typologies =
      development_uuids
      |> Developments.Listings.typologies()
      |> Enum.reduce(%{}, fn typology, map ->
        Map.update(
          map,
          typology.development_uuid,
          [typology],
          &(&1 ++ [typology])
        )
      end)

    Enum.map(development_uuids, fn uuid ->
      %{col => uuid, typologies: Map.get(typologies, uuid, [])}
    end)
  end
end
