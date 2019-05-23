defmodule ReIntegrations.Importers.Importer do
  @moduledoc """
  Context module to use importers.
  """

  def get_building_from_orulo(id) do
    Importers.Orulo.Client.get_building(id)
  end
end
