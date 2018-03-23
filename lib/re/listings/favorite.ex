defmodule Re.Listings.Favorite do
  @moduledoc """
  Schema module for listing favorites
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "listings_favorites" do
    belongs_to :listing, Re.Listing
    belongs_to :user, Re.User

    timestamps()
  end

  @required ~w(listing_id user_id)a
  @optional ~w()a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
