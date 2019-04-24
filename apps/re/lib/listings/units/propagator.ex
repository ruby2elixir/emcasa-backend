defmodule Re.Listings.Units.Propagator do
  @moduledoc """
  Context module for listing units interactions, usually changes in units would
  be replicated/reflected in listings until we migrate replicated structure to units.
  """

  alias Re.Listings

  def update_listing(listing, []), do: {:ok, listing}

  def update_listing(listing, units) do
    unit = Enum.min_by(units, fn unit -> Map.get(unit, :price) end)

    params = %{
      complement: unit.complement,
      price: unit.price,
      property_tax: unit.property_tax,
      maintenance_fee: unit.maintenance_fee,
      floor: unit.floor,
      rooms: unit.rooms,
      bathrooms: unit.bathrooms,
      restrooms: unit.restrooms,
      area: unit.area,
      garage_spots: unit.garage_spots,
      garage_type: unit.garage_type,
      suites: unit.suites,
      balconies: unit.balconies
    }

    Listings.update_from_unit_params(listing, params)
  end
end
