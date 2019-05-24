defmodule ReIntegrations.Orulo do
  @moduledoc """
  Context module to use importers.
  """
  alias ReIntegrations.Orulo.FetchJobQueue

  def get_building_payload(id) do
    %{"type" => "import_development_from_orulo", "external_id" => id}
    |> FetchJobQueue.new()
    |> Re.Repo.insert()
  end
end
