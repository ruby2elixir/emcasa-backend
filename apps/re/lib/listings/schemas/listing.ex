defmodule Re.Listing do
  @moduledoc """
  Model for listings, that is, each apartment or real estate piece on sale.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "listings" do
    field(:type, :string)
    field(:complement, :string)
    field(:description, :string)
    field(:price, :integer)
    field(:property_tax, :float)
    field(:maintenance_fee, :float)
    field(:floor, :string)
    field(:rooms, :integer)
    field(:bathrooms, :integer)
    field(:restrooms, :integer)
    field(:area, :integer)
    field(:garage_spots, :integer, default: 0)
    field(:score, :integer)
    field(:suites, :integer)
    field(:dependencies, :integer)
    field(:balconies, :integer)
    field(:has_elevator, :boolean)
    field(:matterport_code, :string)
    field(:is_active, :boolean, default: false)
    field(:is_exclusive, :boolean, default: false)
    field(:is_release, :boolean)
    field(:visualisations, :integer, virtual: true)
    field(:favorite_count, :integer, virtual: true)
    field(:interest_count, :integer, virtual: true)
    field(:in_person_visit_count, :integer, virtual: true)

    belongs_to(:address, Re.Address)
    belongs_to(:user, Re.User)
    has_many(:images, Re.Image)
    has_many(:price_history, Re.Listings.PriceHistory)
    has_many(:listings_visualisations, Re.Statistics.ListingVisualization)
    has_many(:tour_visualisations, Re.Statistics.TourVisualization)
    has_many(:in_person_visits, Re.Statistics.InPersonVisit)

    has_many(:listings_favorites, Re.Favorite)
    has_many(:favorited, through: [:listings_favorites, :user])

    has_many(:listings_blacklists, Re.Blacklist)
    has_many(:blacklisted, through: [:listings_blacklists, :user])

    has_many(:interests, Re.Interest)

    has_one(:vivareal_highlight, Re.Listings.Highlights.Vivareal)
    has_one(:zap_highlight, Re.Listings.Highlights.Zap)
    has_one(:zap_super_highlight, Re.Listings.Highlights.ZapSuper)

    timestamps()
  end

  @types ~w(Apartamento Casa Cobertura)

  @user_required ~w(type)a
  @user_optional ~w(description price rooms bathrooms area garage_spots
                    address_id user_id suites dependencies has_elevator
                    complement floor is_exclusive property_tax maintenance_fee
                    balconies restrooms is_release)a
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
  end

  @admin_required ~w(type description price rooms bathrooms
                     area garage_spots score address_id user_id
                     suites dependencies has_elevator)a
  @admin_optional ~w(complement floor matterport_code is_exclusive
                     property_tax maintenance_fee balconies restrooms is_release)a
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
end
