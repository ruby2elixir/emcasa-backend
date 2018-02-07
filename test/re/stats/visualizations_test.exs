defmodule Re.VisualizationsTest do
  use Re.ModelCase

  alias Re.{
    Stats.Visualizations,
    Stats.ListingVisualization
  }

  import Re.Factory

  describe "listing/1" do
    test "should insert listing visualization with user" do
      listing = insert(:listing)
      user = insert(:user)
      Visualizations.listing(listing, user)
      :timer.sleep(500)
      assert [%{listing_id: _, user_id: _}] = Repo.all(ListingVisualization)
    end

    test "should insert listing visualization without user" do
      %{id: id} = listing = insert(:listing)
      Visualizations.listing(listing, nil, %{something: "something", more: %{another_thing: 1}})
      :timer.sleep(500)

      assert [
               %{
                 listing_id: ^id,
                 details: %{"something" => "something", "more" => %{"another_thing" => 1}}
               }
             ] = Repo.all(ListingVisualization)
    end
  end
end
