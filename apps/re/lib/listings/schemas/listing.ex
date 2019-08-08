defmodule Re.Listing do
  @moduledoc """
  Model for listings, that is, each apartment or real estate piece on sale.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Re.Listings.Liquidity

  schema "listings" do
    field :uuid, Ecto.UUID
    field :type, :string
    field :complement, :string
    field :description, :string
    field :price, :integer
    field :property_tax, :float
    field :maintenance_fee, :float
    field :floor, :string
    field :rooms, :integer
    field :bathrooms, :integer
    field :restrooms, :integer
    field :area, :integer
    field :garage_spots, :integer, default: 0
    field :garage_type, :string
    field :suites, :integer
    field :dependencies, :integer
    field :balconies, :integer
    field :has_elevator, :boolean
    field :matterport_code, :string
    field :is_active, :boolean, default: false
    field :status, :string, default: "inactive"
    field :is_exclusive, :boolean, default: false
    field :is_release, :boolean, default: false
    field :is_exportable, :boolean, default: true
    field :orientation, :string
    field :floor_count, :integer
    field :unit_per_floor, :integer
    field :sun_period, :string
    field :elevators, :integer
    field :construction_year, :integer
    field :price_per_area, :float
    field :suggested_price, :float

    field :deactivation_reason, :string
    field :sold_price, :integer
    field :liquidity_ratio, :float

    belongs_to :address, Re.Address

    belongs_to :development, Re.Development,
      references: :uuid,
      foreign_key: :development_uuid,
      type: Ecto.UUID

    belongs_to :user, Re.User

    belongs_to :owner_contact, Re.OwnerContact,
      references: :uuid,
      foreign_key: :owner_contact_uuid,
      type: Ecto.UUID

    has_many :images, Re.Image
    has_many :price_history, Re.Listings.PriceHistory

    has_many :listings_favorites, Re.Favorite
    has_many :favorited, through: [:listings_favorites, :user]

    has_many :interests, Re.Interest

    has_many :units, Re.Unit

    many_to_many :tags, Re.Tag,
      join_through: Re.ListingTag,
      join_keys: [listing_uuid: :uuid, tag_uuid: :uuid],
      on_replace: :delete

    timestamps()
  end

  @types ~w(Apartamento Casa Cobertura)

  @garage_types ~w(contract condominium)

  @orientation_types ~w(frontside backside lateral inside)

  @sun_period_types ~w(morning evening)

  @deactivation_reasons ~w(duplicated gave_up left_emcasa publication_mistake rented
                           rejected sold sold_by_emcasa temporarily_suspended to_be_published
                           went_exclusive)

  @required ~w(type description price rooms bathrooms area garage_spots garage_type
                     address_id user_id suites dependencies has_elevator)a
  @optional ~w(complement floor matterport_code is_exclusive status property_tax
                     maintenance_fee balconies restrooms is_release is_exportable
                     orientation floor_count unit_per_floor sun_period elevators
                     construction_year owner_contact_uuid suggested_price
                     deactivation_reason sold_price)a

  @attributes @required ++ @optional

  @price_lower_limit 200_000
  @price_upper_limit 100_000_000

  def changeset(struct, params) do
    struct
    |> cast(params, @attributes)
    |> validate_attributes()
    |> validate_number(
      :price,
      greater_than_or_equal_to: @price_lower_limit,
      less_than_or_equal_to: @price_upper_limit
    )
    |> validate_inclusion(:type, @types)
    |> validate_inclusion(:garage_type, @garage_types)
    |> validate_inclusion(:orientation, @orientation_types)
    |> validate_inclusion(:sun_period, @sun_period_types)
    |> validate_inclusion(:deactivation_reason, @deactivation_reasons)
    |> generate_uuid()
    |> calculate_price_per_area()
    |> calculate_liquidity()
  end

  @development_required ~w(type description price area address_id development_uuid)a

  @development_optional ~w(rooms bathrooms garage_spots garage_type
                     suites dependencies complement floor matterport_code
                     is_exclusive status property_tax
                     maintenance_fee balconies restrooms is_release is_exportable
                     orientation floor_count unit_per_floor sun_period elevators
                     construction_year)a

  @development_attributes @development_required ++ @development_optional

  def development_changeset(struct, params) do
    struct
    |> cast(params, @development_attributes)
    |> cast_assoc(:development)
    |> validate_required(@development_required)
    |> validate_inclusion(:type, @types)
    |> generate_uuid()
  end

  def changeset_update_tags(struct, tags) do
    struct
    |> change()
    |> put_assoc(:tags, tags)
  end

  @more_than_zero_attributes ~w(property_tax maintenance_fee
                                bathrooms garage_spots suites
                                dependencies balconies restrooms)a

  defp validate_attributes(changeset) do
    Enum.reduce(@more_than_zero_attributes, changeset, &greater_than/2)
  end

  defp greater_than(attr, changeset) do
    validate_number(changeset, attr, greater_than_or_equal_to: 0)
  end

  def listing_types(), do: @types

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)

  defp calculate_price_per_area(
         %Ecto.Changeset{valid?: true, changes: %{price: price, area: area}} = changeset
       ) do
    set_price_per_area(price, area, changeset)
  end

  defp calculate_price_per_area(
         %Ecto.Changeset{valid?: true, changes: %{price: price}, data: %{area: area}} = changeset
       ) do
    set_price_per_area(price, area, changeset)
  end

  defp calculate_price_per_area(
         %Ecto.Changeset{valid?: true, changes: %{area: area}, data: %{price: price}} = changeset
       ) do
    set_price_per_area(price, area, changeset)
  end

  defp calculate_price_per_area(
         %Ecto.Changeset{valid?: true, data: %{price: price, area: area}} = changeset
       ) do
    set_price_per_area(price, area, changeset)
  end

  defp calculate_price_per_area(changeset), do: changeset

  defp set_price_per_area(0, _, changeset), do: changeset
  defp set_price_per_area(nil, _, changeset), do: changeset
  defp set_price_per_area(_, 0, changeset), do: changeset
  defp set_price_per_area(_, nil, changeset), do: changeset

  defp set_price_per_area(price, area, changeset) do
    put_change(changeset, :price_per_area, price / area)
  end

  defp calculate_liquidity(changeset) do
    price = get_field(changeset, :price, 0)
    suggested_price = get_field(changeset, :suggested_price, 0)
    put_change(changeset, :liquidity_ratio, Liquidity.calculate(price, suggested_price))
  end
end
