defmodule Re.Listing do
  @moduledoc """
  Model for listings, that is, each apartment or real estate piece on sale.
  """
  use Ecto.Schema

  import Ecto.Changeset

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
    |> cast(params, ~w(type complement description price floor rooms bathrooms area garage_spots score matterport_code is_active address_id)a)
    |> validate_required(~w(type complement description price floor rooms bathrooms area garage_spots score address_id)a)
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_number(:bathrooms, greater_than_or_equal_to: 0)
    |> validate_number(:garage_spots, greater_than_or_equal_to: 0)
    |> validate_number(:score, greater_than: 0, less_than: 5)
    |> validate_length(:type, max: 32)
    |> validate_length(:complement, max: 32)
  end

end
