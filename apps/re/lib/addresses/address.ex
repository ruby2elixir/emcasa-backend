defmodule Re.Address do
  @moduledoc """
  Model for addresses.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Re.Slugs

  schema "addresses" do
    field :uuid, Ecto.UUID
    field :street, :string
    field :street_number, :string
    field :neighborhood, :string
    field :city, :string
    field :state, :string
    field :postal_code, :string
    field :lat, :float
    field :lng, :float

    field :street_slug, :string
    field :neighborhood_slug, :string
    field :city_slug, :string
    field :state_slug, :string

    has_many :listings, Re.Listing
    has_many :developments, Re.Development

    timestamps()
  end

  @required ~w(street street_number neighborhood city state postal_code lat lng)a

  @sluggified_attr ~w(state city neighborhood street)a

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
    |> generate_slugs()
    |> generate_uuid()
  end

  def generate_slugs(%{valid?: false} = changeset), do: changeset

  def generate_slugs(changeset) do
    Enum.reduce(@sluggified_attr, changeset, &Slugs.generate_slug(&1, &2))
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
