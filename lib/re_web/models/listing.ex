defmodule ReWeb.Listing do
  @moduledoc """
  Model for listings, that is, each apartment or real estate piece on sale.
  """

  use ReWeb, :model

  schema "listings" do
    field :type, :string
    field :description, :string
    field :price, :integer
    field :floor, :string
    field :rooms, :integer
    field :bathrooms, :integer
    field :area, :integer
    field :garage_spots, :integer
    field :score, :integer
    field :matterport_code, :string
    field :is_active, :boolean
    belongs_to :address, ReWeb.Address
    has_many :images, ReWeb.Image

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:type, :description, :price, :floor, :rooms, :bathrooms, :area, :garage_spots, :score, :matterport_code, :is_active])
    |> validate_required([:description, :price, :rooms, :area])
  end
end
