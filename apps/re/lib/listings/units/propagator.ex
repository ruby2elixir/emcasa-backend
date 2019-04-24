defmodule Re.Listings.Units.Propagator do
  @moduledoc """
  Context module for listing units interactions, usually changes in units would
  be replicated/reflected in listings until we migrate replicated structure to units.
  """

  alias Re.Listings

  @cloned_attributes ~w(complement price property_tax maintenance_fee floor rooms bathrooms
    restrooms area garage_spots garage_type suites balconies)a

  def update_listing(listing, []), do: {:ok, listing}

  def update_listing(listing, units) do
    params =
      Enum.min_by(units, fn unit -> Map.get(unit, :price) end)
      |> Map.take(@cloned_attributes)

    Listings.update_from_unit_params(listing, params)
  end
end
