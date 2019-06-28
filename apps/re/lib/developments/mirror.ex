defmodule Re.Developments.Mirror do
  @moduledoc """
  Mirror developments and unit info on listings.
  """

  alias Re.{
    Developments.Listings,
    Repo
  }

  def mirror_unit_update(uuid) do
    %{listing: listing, development: %{address: address} = development} =
      unit =
      Repo.get(Re.Unit, uuid)
      |> Repo.preload(development: [:address], listing: [])

    params =
      unit
      |> to_params()

    Listings.update(listing, params, development: development, address: address)
  end

  @unit_cloned_attributes ~w(area price rooms bathrooms garage_spots garage_type suites complement
                            floor status property_tax maintenance_fee balconies restrooms
                            matterport_code is_exportable)a

  defp to_params(unit) do
    Map.take(unit, @unit_cloned_attributes)
  end
end
