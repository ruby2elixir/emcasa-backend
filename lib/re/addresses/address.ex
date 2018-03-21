defmodule Re.Address do
  @moduledoc """
  Model for addresses.
  """
  use Ecto.Schema

  import Ecto.Changeset

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
    |> validate_number(:lat, greater_than: -90, less_than: 90)
    |> validate_number(:lng, greater_than: -180, less_than: 180)
  end
end
