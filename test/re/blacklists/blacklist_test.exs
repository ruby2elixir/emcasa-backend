defmodule Re.FavoritesTest do
  use Re.ModelCase

  alias Re.{
    Blacklist,
    Blacklists
  }

  import Re.Factory

  describe "users/1" do
    test "should return blacklisted users" do
      [user1, user2, user3] = insert_list(3, :user)
      listing = insert(:listing)
      insert(:listing_blacklist, listing_id: listing.id, user_id: user1.id)
      insert(:listing_blacklist, listing_id: listing.id, user_id: user2.id)
      insert(:listing_blacklist, listing_id: listing.id, user_id: user3.id)

      assert [^user1, ^user2, ^user3] = Blacklists.users(listing)
    end
  end

  describe "add/2" do
    test "should blacklist only once" do
      %{id: user_id} = user = insert(:user)
      %{id: listing_id} = listing = insert(:listing)

      refute Repo.get_by(Blacklist, listing_id: listing.id, user_id: user.id)

      assert {:ok, %{listing_id: ^listing_id, user_id: ^user_id}} = Blacklists.add(listing, user)

      assert Repo.get_by(Blacklist, listing_id: listing.id, user_id: user.id)

      assert {:ok, %{listing_id: ^listing_id, user_id: ^user_id}} = Blacklists.add(listing, user)

      assert Repo.get_by(Blacklist, listing_id: listing.id, user_id: user.id)
    end
  end

  describe "remove/2" do
    test "should remove blacklisted listing" do
      %{id: user_id} = user = insert(:user)
      %{id: listing_id} = listing = insert(:listing)
      insert(:listing_blacklist, listing_id: listing_id, user_id: user_id)

      assert {:ok, %{listing_id: ^listing_id, user_id: ^user_id}} =
               Blacklists.remove(listing, user)

      refute Repo.get_by(Blacklist, listing_id: listing_id, user_id: user_id)
    end

    test "should error if it doesn't exist" do
      assert {:error, :not_found} = Blacklists.remove(%{id: -1}, %{id: -1})
    end
  end
end
