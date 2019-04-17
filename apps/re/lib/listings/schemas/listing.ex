defmodule Re.Listing do
  @moduledoc """
  Model for listings, that is, each apartment or real estate piece on sale.
  """
  use Ecto.Schema

  import Ecto.Changeset

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
    field :score, :integer
    field :suites, :integer
    field :dependencies, :integer
    field :balconies, :integer
    field :has_elevator, :boolean
    field :matterport_code, :string
    field :is_active, :boolean, default: false
    field :status, :string, default: "inactive"
    field :is_exclusive, :boolean, default: false
    field :is_release, :boolean
    field :is_exportable, :boolean, default: true
    field :orientation, :string
    field :floor_count, :integer
    field :unit_per_floor, :integer
    field :sun_period, :string
    field :elevators, :integer
    field :construction_year, :integer
    field :price_per_area, :float
    field :visualisations, :integer, virtual: true
    field :favorite_count, :integer, virtual: true
    field :interest_count, :integer, virtual: true
    field :in_person_visit_count, :integer, virtual: true

    belongs_to :address, Re.Address

    belongs_to :development, Re.Development,
      references: :uuid,
      foreign_key: :development_uuid,
      type: Ecto.UUID

    belongs_to :user, Re.User

    has_many :images, Re.Image
    has_many :price_history, Re.Listings.PriceHistory
    has_many :listings_visualisations, Re.Statistics.ListingVisualization
    has_many :tour_visualisations, Re.Statistics.TourVisualization
    has_many :in_person_visits, Re.Statistics.InPersonVisit

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

  @user_required ~w(type)a
  @user_optional ~w(description price rooms bathrooms area garage_spots garage_type address_id
                    user_id suites dependencies has_elevator complement floor is_exclusive
                    property_tax maintenance_fee balconies restrooms is_release)a
  @user_attributes @user_required ++ @user_optional
  @doc """
  Builds a changeset based on the `struct` and `params` and user role.
  """
  def changeset(struct, params \\ %{}, role \\ "user")

  def changeset(struct, params, "user") do
    struct
    |> cast(params, @user_attributes)
    |> validate_required(@user_required)
    |> validate_attributes()
    |> validate_inclusion(:type, @types, message: "should be one of: [#{Enum.join(@types, " ")}]")
    |> validate_inclusion(:garage_type, @garage_types,
      message: "should be one of: [#{Enum.join(@garage_types, " ")}]"
    )
    |> generate_uuid()
    |> calculate_price_per_area()
  end

  @admin_required ~w(type description price rooms bathrooms area garage_spots garage_type
                     score address_id user_id suites dependencies has_elevator)a
  @admin_optional ~w(complement floor matterport_code is_exclusive status property_tax
                     maintenance_fee balconies restrooms is_release is_exportable
                     orientation floor_count unit_per_floor sun_period elevators
                     construction_year)a

  @admin_attributes @admin_required ++ @admin_optional
  def changeset(struct, params, "admin") do
    struct
    |> cast(params, @admin_attributes)
    |> validate_attributes()
    |> validate_number(
      :price,
      greater_than_or_equal_to: 250_000,
      less_than_or_equal_to: 100_000_000
    )
    |> validate_number(:score, greater_than: 0, less_than: 5)
    |> validate_inclusion(:type, @types, message: "should be one of: [#{Enum.join(@types, " ")}]")
    |> validate_inclusion(:garage_type, @garage_types,
      message: "should be one of: [#{Enum.join(@garage_types, " ")}]"
    )
    |> validate_inclusion(
      :orientation,
      @orientation_types,
      "should be one of: [#{Enum.join(@orientation_types, " ")}]"
    )
    |> validate_inclusion(
      :sun_period,
      @sun_period_types,
      "should be one of: [#{Enum.join(@sun_period_types, " ")}]"
    )
    |> generate_uuid()
    |> calculate_price_per_area()
  end

  @development_required ~w(type description has_elevator address_id user_id development_uuid)a

  @development_optional ~w(matterport_code is_exclusive status is_release)a

  @development_attributes @development_required ++ @development_optional

  def development_changeset(struct, params) do
    struct
    |> cast(params, @development_attributes)
    |> cast_assoc(:development)
    |> validate_required(@development_required)
    |> validate_inclusion(:type, @types, message: "should be one of: [#{Enum.join(@types, " ")}]")
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
end
