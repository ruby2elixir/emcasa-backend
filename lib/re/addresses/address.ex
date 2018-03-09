defmodule Re.Address do
  @moduledoc """
  Model for addresses.
  """
  use Ecto.Schema

  import Ecto.Changeset
  alias Ecto.Changeset

  schema "addresses" do
    field :street, :string
    field :street_number, :string
    field :neighborhood, :string
    field :city, :string
    field :state, :string
    field :postal_code, :string
    field :lat, :float
    field :lng, :float
    has_many :listings, Re.Listing

    timestamps()
  end

  @required ~w(street street_number neighborhood city state postal_code lat lng)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_length(:street, max: 128)
    |> validate_length(:street_number, max: 128)
    |> validate_length(:neighborhood, max: 128)
    |> validate_length(:city, max: 128)
    |> validate_length(:state, is: 2)
    |> unique_constraint(:postal_code, name: :unique_address)
    |> validate_lat()
    |> validate_lng()
  end

  defp validate_lat(changeset) do
    changeset
    |> Changeset.get_field(:lat, nil)
    |> case do
      lat when lat > -90 and lat < 90 -> changeset
      _ -> Changeset.add_error(changeset, :lat, "invalid latitude")
    end
  end

  defp validate_lng(changeset) do
    changeset
    |> Changeset.get_field(:lng, nil)
    |> case do
      lng when lng > -180 and lng < 180 -> changeset
      _ -> Changeset.add_error(changeset, :lng, "invalid longitude")
    end
  end
end
