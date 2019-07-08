defmodule Re.Developments.Listings do
  @moduledoc """
  Module to handle listings for developments (primary market) context.
  """
  alias Re.{
    Listing,
    Listings.Queries,
    PubSub,
    Repo
  }

  alias Ecto.Changeset

  import Ecto.Query, only: [select: 3, where: 3, group_by: 3]

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

  def batch_update(listings, params, opts) do
    Repo.transaction(fn ->
      Enum.map(listings, fn listing -> update(listing, params, opts) end)
    end)
  end

  defp changeset_for_opts(listing, opts) do
    Enum.reduce(opts, Changeset.change(listing), fn
      {:development, development}, changeset ->
        Changeset.change(changeset, %{development_uuid: development.uuid})

      {:address, address}, changeset ->
        Changeset.change(changeset, %{address_id: address.id})

      {:unit, unit}, changeset ->
        Changeset.change(changeset, %{units: [unit]})
    end)
  end

  @unit_cloned_attributes ~w(area price rooms bathrooms garage_spots garage_type
                     suites complement floor matterport_code
                     status property_tax maintenance_fee balconies restrooms is_exportable)a

  @development_cloned_attributes ~w(description floor_count unit_per_floor elevators construction_year)a

  @static_attributes %{
    type: "Apartamento",
    is_release: true,
    is_exportable: false
  }

  def listing_params_from_unit(%Re.Unit{} = unit, %Re.Development{} = development) do
    %{}
    |> merge_with_unit_attributes(unit)
    |> merge_with_development_attributes(development)
    |> Map.merge(@static_attributes)
  end

  defp merge_with_development_attributes(params, development) do
    units_per_floor = Map.get(development, :units_per_floor)

    development
    |> Map.take(@development_cloned_attributes)
    |> Map.put(:unit_per_floor, units_per_floor)
    |> Map.merge(params)
  end

  defp merge_with_unit_attributes(params, unit) do
    unit
    |> Map.take(@unit_cloned_attributes)
    |> Map.merge(params)
  end

  def update_from_unit_params(listing, params) do
    changeset =
      listing
      |> Changeset.change(params)

    changeset
    |> Repo.update()
    |> PubSub.publish_update(changeset, "update_listing")
  end

  def per_development(%Re.Development{uuid: uuid}, preload \\ []) do
    Listing
    |> Queries.per_development(uuid)
    |> Queries.preload_relations(preload)
    |> Repo.all()
 end

  def typologies(development_uuids) when is_list(development_uuids) do
    Listing
    |> select([l], %{
      area: l.area,
      rooms: l.rooms,
      max_price: max(l.price),
      min_price: min(l.price),
      unit_count: count(l.id),
      development_uuid: l.development_uuid
    })
    |> group_by([l], [l.area, l.rooms, l.development_uuid])
    |> where([l], l.development_uuid in ^development_uuids and l.status == "active")
    |> Repo.all
  end
end
