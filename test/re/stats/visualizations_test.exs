defmodule Re.VisualizationsTest do
  use Re.ModelCase

  alias Re.{
    Stats.Visualizations,
    Stats.ListingVisualization
  }

  import ExUnit.CaptureLog
  import Re.Factory

  describe "`handle_cast/2" do
    test "should insert listing visualization with user" do
      %{id: listing_id} = listing = insert(:listing)
      %{id: user_id} = user = insert(:user)
      Visualizations.handle_cast({:listing_visualization, listing.id, user.id, "something"}, [])

      assert [%{listing_id: ^listing_id, user_id: ^user_id}] = Repo.all(ListingVisualization)
    end

    test "should insert listing visualization without user" do
      %{id: listing_id} = listing = insert(:listing)
      Visualizations.handle_cast({:listing_visualization, listing.id, nil, "something"}, [])

      assert [%{listing_id: ^listing_id, details: "something"}] = Repo.all(ListingVisualization)
    end

    test "should not insert visualization without listing" do
      assert capture_log(fn ->
               Visualizations.handle_cast({:listing_visualization, -1, nil, "something"}, [])
             end) =~ "Listing visualization was not inserted: "

      assert [] == Repo.all(ListingVisualization)
    end
  end
end
