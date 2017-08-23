defmodule ReWeb.Listing do
  @moduledoc """
  Model for listings, that is, each apartment or real estate piece on sale.
  """

  use ReWeb, :model

  schema "listings" do
    field :name, :string
    field :description, :string
    field :price, :integer
    field :rooms, :integer
    field :area, :integer
    field :garage_spots, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :price, :rooms, :area, :garage_spots])
    |> validate_required([:description, :name, :price, :rooms, :area])
  end
end
