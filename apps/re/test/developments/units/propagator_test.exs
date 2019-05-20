defmodule Re.Developments.Units.PropagatorTest do
  use Re.ModelCase

  alias Re.Developments.Units.Propagator
  import Re.Factory

  describe "update_listing/2" do
    test "copy infos from the unit with the lowest price" do
      development = insert(:development)

      {:ok, listing} =
        %Re.Listing{}
        |> Re.Repo.insert()

      unit_1 =
        insert(:unit,
          complement: "100",
          price: 1_000_000,
          property_tax: 1_000,
          maintenance_fee: 1_000,
          floor: "first",
          rooms: 1,
          bathrooms: 1,
          restrooms: 1,
          area: 100,
          garage_spots: 1,
          garage_type: "contract",
          suites: 1,
          balconies: 1,
          status: "active",
          development_uuid: development.uuid,
          listing_id: listing.id
        )

      unit_2 =
        insert(:unit,
          complement: "200",
          price: 2_000_000,
          property_tax: 2_000,
          maintenance_fee: 3_000,
          floor: "second",
          rooms: 2,
          bathrooms: 2,
          restrooms: 2,
          area: 200,
          garage_spots: 2,
          garage_type: "contract",
          suites: 2,
          balconies: 2,
          status: "active",
          development_uuid: development.uuid,
          listing_id: listing.id
        )

      assert {:ok, listing} = Propagator.update_listing(listing, [unit_1, unit_2])
      assert listing.complement == unit_1.complement
      assert listing.price == unit_1.price
      assert listing.property_tax == unit_1.property_tax
      assert listing.maintenance_fee == unit_1.maintenance_fee
      assert listing.floor == unit_1.floor
      assert listing.rooms == unit_1.rooms
      assert listing.bathrooms == unit_1.bathrooms
      assert listing.restrooms == unit_1.restrooms
      assert listing.area == unit_1.area
      assert listing.garage_spots == unit_1.garage_spots
      assert listing.garage_type == unit_1.garage_type
      assert listing.suites == unit_1.suites
      assert listing.balconies == unit_1.balconies
    end
  end
end
