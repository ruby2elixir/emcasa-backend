defmodule Re.Listings.FeaturedListing do
  @moduledoc """
  Model for featured listings to be displayed on the main page
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "featured_listings" do
    field :position, :integer

    belongs_to :listing, Re.Listing

    timestamps()
  end

  @required ~w(listing_id)a
  @optional ~w(position)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
