defmodule ReIntegrations.Orulo do
  @moduledoc """
  Context module to use importers.
  """
  alias ReIntegrations.{
    Orulo.Building,
    Orulo.FetchJobQueue,
    Repo
  }

  alias Ecto.Multi

  def get_building_payload(id) do
    %{"type" => "import_development_from_orulo", "external_id" => id}
    |> FetchJobQueue.new()
    |> Re.Repo.insert()
  end

  def multi_building_insert(multi, params) do
    %Building{}
    |> Building.changeset(params)
    |> insert_building_on_multi(multi)
    |> Repo.transaction()
  end

  defp insert_building_on_multi(changeset, multi) do
    Multi.insert(multi, :building, changeset)
  end
end
