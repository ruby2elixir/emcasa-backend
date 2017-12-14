defmodule Re.Listing do
  @moduledoc """
  Model for listings, that is, each apartment or real estate piece on sale.
  """
  use Ecto.Schema

  import Ecto
  import Ecto.Changeset
  import Ecto.Query

  schema "listings" do
    field :type, :string
    field :complement, :string
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
    belongs_to :address, Re.Address
    has_many :images, Re.Image

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:type, :complement, :description, :price, :floor, :rooms, :bathrooms, :area, :garage_spots, :score, :matterport_code, :is_active])
    |> validate_required([:type, :complement, :description, :price, :floor, :rooms, :bathrooms, :area, :garage_spots, :score])
  end
end
