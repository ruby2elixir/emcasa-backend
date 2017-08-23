defmodule ReWeb.Address do
  @moduledoc """
  Model for addresses.
  """

  use ReWeb, :model

  schema "addresses" do
    field :street, :string
    field :neighborhood, :string
    field :city, :string
    field :state, :string
    field :postal_code, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:street, :neighborhood, :city, :state, :postal_code])
    |> validate_required([:street, :neighborhood, :city, :state, :postal_code])
  end
end
