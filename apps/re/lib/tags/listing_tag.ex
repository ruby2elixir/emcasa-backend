defmodule Re.ListingTag do
  @moduledoc """
  Model that resolve relation between listing and tag.
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false

  schema "listings_tags" do
    belongs_to :listing, Re.Listing, primary_key: true

    belongs_to :tag, Re.Tag,
      type: :binary_id,
      foreign_key: :tag_uuid,
      references: :uuid,
      primary_key: true
  end

  @required ~w(listing_id tag_uuid)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
