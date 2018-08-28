defmodule Re.Addresses.District do
  @moduledoc """
  Model for districts.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "districts" do
    field :state, :string
    field :city, :string
    field :name, :string
    field :description, :string

    timestamps()
  end

  @required ~w(state city name description)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_length(:name, max: 128)
    |> validate_length(:city, max: 128)
    |> validate_length(:state, is: 2)
    |> unique_constraint(:neighborhood, name: :neighborhood)
  end
end
