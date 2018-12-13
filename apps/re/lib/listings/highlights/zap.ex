defmodule Re.Listings.Highlights.Zap do
  @moduledoc """
  Model for listings highlighted in zap
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "zap_highlights" do
    belongs_to :listing, Re.Listing

    timestamps()
  end

  @attributes ~w(listing_id)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @attributes)
    |> validate_required(@attributes)
    |> unique_constraint(:listing_id)
  end
end
