defmodule Re.Address do
  @moduledoc """
  Model for addresses.
  """
  use Ecto.Schema

  import Ecto.Changeset
  alias Ecto.Changeset

  schema "addresses" do
    field(:street, :string)
    field(:street_number, :string)
    field(:neighborhood, :string)
    field(:city, :string)
    field(:state, :string)
    field(:postal_code, :string)
    field(:lat, :string)
    field(:lng, :string)
    has_many(:listings, Re.Listing)

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
    |> validate_postal_code()
    |> unique_constraint(:postal_code, name: :unique_address)
    |> validate_lat()
    |> validate_lng()
  end

  @postal_code_regex ~r/^[0-9]{5}[-][0-9]{3}$/

  defp validate_postal_code(changeset) do
    postal_code = Changeset.get_field(changeset, :postal_code, "")

    if Regex.match?(@postal_code_regex, postal_code) do
      changeset
    else
      Changeset.add_error(changeset, :postal_code, "postal code didn't match")
    end
  end

  defp validate_lat(changeset) do
    changeset
    |> Changeset.get_field(:lat, "")
    |> Float.parse()
    |> case do
      {latitude, ""} ->
        if latitude > -90 and latitude < 90 do
          changeset
        else
          Changeset.add_error(changeset, :lat, "invalid latitude")
        end

      _ ->
        Changeset.add_error(changeset, :lat, "parsing error")
    end
  end

  defp validate_lng(changeset) do
    changeset
    |> Changeset.get_field(:lng, "")
    |> Float.parse()
    |> case do
      {longitude, ""} ->
        if longitude > -180 and longitude < 180 do
          changeset
        else
          Changeset.add_error(changeset, :lng, "invalid longitude")
        end

      _ ->
        Changeset.add_error(changeset, :lng, "parsing error")
    end
  end
end
