defmodule Re.Listings.ListingsTags do
  @moduledoc """
  Model for joining a listing and a tag.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "listings_tags" do
    belongs_to :listing, Re.Listing, primary_key: true
    belongs_to :tag, Re.Listings.Tag, foreign_key: :tag_uuid, references: :uuid, primary_key: true
  end

  @required ~w(listing_id tag_id)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
