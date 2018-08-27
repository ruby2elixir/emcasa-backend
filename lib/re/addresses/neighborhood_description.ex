defmodule Re.Addresses.NeighborhoodDescription do
  @moduledoc """
  Model for neighborhood description.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "neighborhood_descriptions" do
    field :state, :string
    field :city, :string
    field :neighborhood, :string
    field :description, :string

    timestamps()
  end

  @required ~w(state city neighborhood description)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_length(:neighborhood, max: 128)
    |> validate_length(:city, max: 128)
    |> validate_length(:state, is: 2)
    |> unique_constraint(:neighborhood, name: :neighborhood)
  end
end
