defmodule ReWeb.Address do
  @moduledoc """
  Model for addresses.
  """

  use ReWeb, :model

  schema "addresses" do
    field :street, :string
    field :street_number, :string
    field :neighborhood, :string
    field :city, :string
    field :state, :string
    field :postal_code, :string
    field :lat, :string
    field :lng, :string
    has_many :listings, ReWeb.Listing

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:street, :neighborhood, :city, :state, :postal_code, :street_number, :lat, :lng])
    |> validate_required([:street, :street_number, :neighborhood, :city, :state, :postal_code, :lat, :lng])
  end
end
