defmodule Re.FavoritesTest do
  use Re.ModelCase

  alias Re.{
    Favorite,
    Listing,
    Listings
  }

  import Re.Factory

  describe "favorited_users/1" do
    test "should return favorited users" do
      [user1, user2, user3] = insert_list(3, :user)
      listing = insert(:listing)
      insert(:listing_favorite, listing_id: listing.id, user_id: user1.id)
      insert(:listing_favorite, listing_id: listing.id, user_id: user2.id)
      insert(:listing_favorite, listing_id: listing.id, user_id: user3.id)

      assert [^user1, ^user2, ^user3] = Listings.favorited_users(listing)
    end
  end

  describe "favorite/2" do
    test "should favorite only once" do
      %{id: user_id} = user = insert(:user)
      %{id: listing_id} = listing = insert(:listing)

      assert {:ok, %{listing_id: ^listing_id, user_id: ^user_id}} =
               Listings.favorite(listing, user)

      assert {:ok, %{listing_id: ^listing_id, user_id: ^user_id}} =
               Listings.favorite(listing, user)

      assert {:ok, %{listing_id: ^listing_id, user_id: ^user_id}} =
               Listings.favorite(listing, user)

      assert Repo.get_by(Favorite, listing_id: listing.id, user_id: user.id)
    end
  end
end
