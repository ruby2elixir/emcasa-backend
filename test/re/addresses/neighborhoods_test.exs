defmodule Re.NeighborhoodsTest do
  use Re.ModelCase

  alias Re.Neighborhoods

  import Re.Factory

  describe "all" do
    test "should return only addresses with active listing" do
      address1 = insert(:address, neighborhood: "Test 1")
      insert(:listing, address: address1)
      insert(:listing, address: address1)
      address2 = insert(:address, neighborhood: "Test 2")
      insert(:listing, address: address2, is_active: false)

      assert ["Test 1"] == Neighborhoods.all()
    end
  end
end
