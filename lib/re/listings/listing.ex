defmodule Re.Listing do
  @moduledoc """
  Model for listings, that is, each apartment or real estate piece on sale.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "listings" do
    field :type, :string
    field :complement, :string
    field :description, :string
    field :price, :integer
    field :property_tax, :float
    field :maintenance_fee, :float
    field :floor, :string
    field :rooms, :integer
    field :bathrooms, :integer
    field :area, :integer
    field :garage_spots, :integer
    field :score, :integer
    field :suites, :integer
    field :dependencies, :integer
    field :has_elevator, :boolean
    field :matterport_code, :string
    field :is_active, :boolean, default: false
    field :is_exclusive, :boolean, default: false

    belongs_to :address, Re.Address
    belongs_to :user, Re.User
    has_many :images, Re.Image

    timestamps()
  end

  @types ~w(Apartamento Casa Cobertura)

  @required ~w(type description price rooms bathrooms
               area garage_spots score address_id user_id
               suites dependencies has_elevator)a
  @optional ~w(complement floor matterport_code is_active is_exclusive
               property_tax maintenance_fee)a

  @attributes (@required ++ @optional)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @attributes)
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_number(:property_tax, greater_than_or_equal_to: 0)
    |> validate_number(:maintenance_fee, greater_than_or_equal_to: 0)
    |> validate_number(:bathrooms, greater_than_or_equal_to: 0)
    |> validate_number(:garage_spots, greater_than_or_equal_to: 0)
    |> validate_number(:suites, greater_than_or_equal_to: 0)
    |> validate_number(:dependencies, greater_than_or_equal_to: 0)
    |> validate_number(:score, greater_than: 0, less_than: 5)
    |> validate_inclusion(:type, @types, message: "should be one of: [#{Enum.join(@types, " ")}]")
  end
end
