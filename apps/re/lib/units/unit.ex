defmodule Re.Unit do
  @moduledoc """
  Model for real estate commom properties, each real estate can have one
  or more units.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "units" do
    field :uuid, Ecto.UUID
    field :complement, :string
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

    belongs_to :listing, Re.Listing
    timestamps()
  end

  @garage_types ~w(contract condominium)

  @required ~w(price rooms bathrooms area garage_type garage_spots suites dependencies)a
  @optional ~w(complement floor property_tax maintenance_fee balconies restrooms)a

  @attributes @required ++ @optional

  def changeset(struct, params, "development") do
    struct
    |> cast(params, @attributes)
    |> validate_required(@required)
    |> validate_attributes()
    |> validate_number(
      :price,
      greater_than_or_equal_to: 250_000,
      less_than_or_equal_to: 100_000_000
    )
    |> validate_inclusion(:garage_type, @garage_types,
      message: "should be one of: [#{Enum.join(@garage_types, " ")}]"
    )
    |> generate_uuid()
    |> unique_constraint(:uuid, name: :uuid)
  end

  def uuid_changeset(struct, params), do: cast(struct, params, ~w(uuid)a)

  @non_negative_attributes ~w(property_tax maintenance_fee
                              bathrooms garage_spots suites
                              dependencies balconies restrooms)a

  defp validate_attributes(changeset) do
    Enum.reduce(@non_negative_attributes, changeset, &non_negative/2)
  end

  defp non_negative(attr, changeset) do
    validate_number(changeset, attr, greater_than_or_equal_to: 0)
  end

  defp generate_uuid(changeset), do: Ecto.Changeset.change(changeset, %{uuid: UUID.uuid4()})
end
