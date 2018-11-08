defmodule Re.Listings.Highlights.ZapSuper do
  @moduledoc """
  Model for listings super highlighted in zap
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "zap_super_highlights" do
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
