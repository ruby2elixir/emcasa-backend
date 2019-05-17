defmodule Re.Developments.Listings do
  @moduledoc """
  Module to handle listings for developments (primary market) context.
  """
  alias Re.{
    Listing,
    PubSub,
    Repo
  }

  alias Ecto.Changeset

  def insert(params, opts) do
    %Listing{}
    |> changeset_for_opts(opts)
    |> Listing.development_changeset(params)
    |> Repo.insert()
  end

  def update(listing, params, opts) do
    changeset =
      listing
      |> changeset_for_opts(opts)
      |> Listing.development_changeset(params)

    changeset
    |> Repo.update()
    |> PubSub.publish_update(changeset, "update_listing")
  end

  defp changeset_for_opts(listing, opts) do
    Enum.reduce(opts, Changeset.change(listing), fn
      {:development, development}, changeset ->
        Changeset.change(changeset, %{development_uuid: development.uuid})

      {:address, address}, changeset ->
        Changeset.change(changeset, %{address_id: address.id})
    end)
  end

  @unit_cloned_attributes ~w(area price rooms bathrooms garage_spots garage_type
                     suites complement floor matterport_code
                     status property_tax maintenance_fee balconies restrooms is_release is_exportable)a

  @development_cloned_attributes ~w(description floor_count unit_per_floor elevators construction_year)a

  @static_attributes %{
    type: "Apartamento",
    is_release: true,
    garage_type: "unknown"
  }

  def listing_from_unit(%Re.Unit{} = unit, %Re.Development{} = development) do
    params_from_unit = extract_listing_params_from_unit(unit)
    params_from_development = extract_listing_params_from_development(development)

    %Re.Listing{}
    |> Map.merge(params_from_unit)
    |> Map.merge(params_from_development)
    |> Map.merge(@static_attributes)
  end

  defp extract_listing_params_from_development(development) do
    units_per_floor = Map.get(development, :units_per_floor)

    Map.take(development, @development_cloned_attributes)
    |> Map.put(:unit_per_floor, units_per_floor)
  end

  defp extract_listing_params_from_unit(unit) do
    Map.take(unit, @unit_cloned_attributes)
  end

  def update_from_unit_params(listing, params) do
    changeset =
      listing
      |> Changeset.change(params)

    changeset
    |> Repo.update()
    |> PubSub.publish_update(changeset, "update_listing")
  end
end
