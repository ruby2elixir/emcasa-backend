defmodule Re.Listings.Units.ServerTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.Listings.Units.Server

  describe "handle_info/2" do
    @insert_unit_params %{
      price: 500_000,
      status: "active"
    }

    test "match new_unit topic" do
      development = insert(:development)
      listing = insert(:listing, price: 1_000_000, development_uuid: development.uuid)
      attrs = Map.merge(@insert_unit_params, %{listing_id: listing.id})
      new_unit = insert(:unit, attrs)

      assert {:noreply, []} ==
               Server.handle_info(
                 %{
                   topic: "new_unit",
                   type: :new,
                   content: %{
                     new: new_unit
                   }
                 },
                 []
               )
    end

    test "match updated_unit topic" do

    end
  end
end
