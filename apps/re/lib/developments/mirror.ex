defmodule Re.Developments.Mirror do
  @moduledoc """
  Mirror developments and unit info on listings.
  """
  require Ecto.Query
  require Logger

  alias Re.{
    Developments,
    Developments.Listings,
    Units
  }

  @unit_preload_for_insert [development: [:address]]

  def mirror_unit_insert_to_listing(uuid) do
    {:ok, %{development: %{address: address} = development} = unit} =
      Units.get_preloaded(uuid, @unit_preload_for_insert)

    unit
    |> Listings.listing_params_from_unit(development)
    |> Listings.insert(development: development, address: address, unit: unit)
  end

  @unit_preload_for_update [development: [:address], listing: []]

  def mirror_unit_update_to_listing(uuid) do
    {:ok, %{listing: listing, development: %{address: address} = development} = unit} =
      Units.get_preloaded(uuid, @unit_preload_for_update)

    params =
      unit
      |> to_params()

    Listings.update(listing, params, development: development, address: address)
  end

  def mirror_development_update_to_listings(uuid) do
    {:ok, development = %{address: address}} =
      Developments.get_preloaded(uuid, [:address, :units])

    listings = Listings.per_development(development, [:units])

    params =
      development
      |> to_params()

    Listings.batch_update(listings, params,
      address: address,
      development: development
    )
  end

  @unit_cloned_attributes ~w(area price rooms bathrooms garage_spots garage_type suites complement
                            floor property_tax maintenance_fee balconies restrooms
                            matterport_code is_exportable)a

  defp to_params(%Re.Unit{} = unit) do
    Map.take(unit, @unit_cloned_attributes)
  end

  @development_cloned_attributes ~w(description floor_count elevators)a

  defp to_params(%Re.Development{} = development) do
    development
    |> Map.take(@development_cloned_attributes)
    |> Map.put(:unit_per_floor, Map.get(development, :units_per_floor))
  end
end
