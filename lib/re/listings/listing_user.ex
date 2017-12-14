defmodule Re.ListingUser do
  @moduledoc false
  use Ecto.Schema

  import Ecto
  import Ecto.Changeset
  import Ecto.Query

  schema "listings_users" do
    belongs_to :listing, Re.Listing
    belongs_to :user, Re.User
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:listing_id, :user_id])
  end
end
