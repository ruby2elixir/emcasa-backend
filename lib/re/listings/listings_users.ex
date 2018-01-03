defmodule Re.ListingsUsers do

  alias Re.{
    User,
    ListingUser,
    Repo
  }

  def insert_user(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert(on_conflict: :replace_all, conflict_target: :email)
  end

  def insert_listing_user(user_id, listing_id) do
    %ListingUser{}
    |> ListingUser.changeset(%{user_id: user_id, listing_id: listing_id})
    |> Repo.insert()
  end

end
