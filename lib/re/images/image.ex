defmodule Re.Image do
  @moduledoc """
  Module for listing images.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "images" do
    field(:filename, :string)
    field(:position, :integer)
    belongs_to(:listing, Re.Listing)

    timestamps()
  end

  @required ~w(filename position)a
  @optional ~w(listing_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end

  def position_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:position])
    |> validate_required([:position])
  end
end
