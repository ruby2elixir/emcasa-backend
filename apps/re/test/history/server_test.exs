defmodule Re.History.ServerTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    History.Server,
    Listing,
    Listings.PriceHistory,
    Repo
  }

  describe "handle_info/2" do
    test "save price when it's updated" do
      listing = insert(:listing)
      changeset = Listing.changeset(listing, %{price: listing.price + 50}, "admin")

      Server.handle_info(
        %{
          topic: "update_listing",
          type: :update,
          content: %{
            new: listing,
            changeset: changeset
          }
        },
        []
      )

      assert [_] = Repo.all(PriceHistory)
    end

    test "do not save price when it's not updated" do
      listing = insert(:listing)
      changeset = Listing.changeset(listing, %{description: "descr"}, "admin")

      Server.handle_info(
        %{
          topic: "update_listing",
          type: :update,
          content: %{
            new: listing,
            changeset: changeset
          }
        },
        []
      )

      assert [] == Repo.all(PriceHistory)
    end
  end
end
