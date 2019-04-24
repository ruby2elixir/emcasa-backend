defmodule Re.Listings.Units.Propagator do
  @moduledoc """
  Context module for listing units interactions, usually changes in units would
  be replicated/reflected in listings until we migrate replicated structure to units.
  """

  alias Ecto.Changeset
  alias Re.Listings

  def update_listing(listing, []), do: {:ok, listing}

  def update_listing(listing, units) do
    head = Enum.min_by(units, fn unit -> Map.get(unit, :price) end)

    params = %{
      complement: head.complement,
      price: head.price,
      property_tax: head.property_tax,
      maintenance_fee: head.maintenance_fee,
      floor: head.floor,
      rooms: head.rooms,
      bathrooms: head.bathrooms,
      restrooms: head.restrooms,
      area: head.area,
      garage_spots: head.garage_spots,
      garage_type: head.garage_type,
      suites: head.suites,
      balconies: head.balconies
    }

    listing
    |> Changeset.change(params)
    |> Re.Repo.update()
  end
end
