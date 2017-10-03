defmodule ReWeb.ListingUser do
  @moduledoc false

  use ReWeb, :model

  schema "listings_users" do
    belongs_to :listing, ReWeb.Listing
    belongs_to :user, ReWeb.User
  end
end
