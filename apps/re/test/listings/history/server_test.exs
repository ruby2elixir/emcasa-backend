defmodule Re.Listings.History.ServerTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    Listing,
    Listings.History.Server,
    Listings.PriceHistory,
    Listings.StatusHistory,
    Repo
  }

  describe "handle_info/2" do
    test "save price when it's updated" do
      listing = insert(:listing)
      changeset = Listing.changeset(listing, %{price: listing.price + 50})

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
      changeset = Listing.changeset(listing, %{description: "descr"})

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

    test "save status history when it's activated" do
      listing = insert(:listing, status: "inactive")
      changeset = Listing.changeset(listing, %{status: "active"})

      Server.handle_info(
        %{
          topic: "activate_listing",
          type: :update,
          content: %{
            new: listing,
            changeset: changeset
          }
        },
        []
      )

      assert [_] = Repo.all(StatusHistory)
    end

    test "save status history when it's deactivated" do
      listing = insert(:listing, status: "active")
      changeset = Listing.changeset(listing, %{status: "inactive"})

      Server.handle_info(
        %{
          topic: "deactivate_listing",
          type: :update,
          content: %{
            new: listing,
            changeset: changeset
          }
        },
        []
      )

      assert [_] = Repo.all(StatusHistory)
    end
  end
end
