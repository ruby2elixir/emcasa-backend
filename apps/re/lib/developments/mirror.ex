defmodule Re.Developments.Mirror do
  @moduledoc """
  Mirror developments and unit info on listings.
  """

  alias Re.{
    Developments.Listings,
    Units
  }

  @unit_preload [development: [:address], listing: []]

  def mirror_unit_update_to_listing(uuid) do
    {:ok, %{listing: listing, development: %{address: address} = development} = unit} =
      Units.get_preloaded(uuid, @unit_preload)

    params =
      unit
      |> to_params()

    Listings.update(listing, params, development: development, address: address)
  end

  @unit_cloned_attributes ~w(area price rooms bathrooms garage_spots garage_type suites complement
                            floor property_tax maintenance_fee balconies restrooms
                            matterport_code is_exportable)a

  defp to_params(unit) do
    Map.take(unit, @unit_cloned_attributes)
  end
end
