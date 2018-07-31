defmodule Re.Blacklist do
  @moduledoc """
  Schema module for listing blacklists
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "listings_blacklists" do
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
    |> unique_constraint(:listing_id, name: :unique_favorite)
  end
end
