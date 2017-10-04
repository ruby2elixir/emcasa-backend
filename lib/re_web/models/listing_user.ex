defmodule ReWeb.ListingUser do
  @moduledoc false

  use ReWeb, :model

  schema "listings_users" do
    belongs_to :listing, ReWeb.Listing
    belongs_to :user, ReWeb.User
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:listing_id, :user_id])
  end
end
