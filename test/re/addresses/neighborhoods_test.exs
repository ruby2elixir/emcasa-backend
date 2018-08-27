defmodule Re.NeighborhoodsTest do
  use Re.ModelCase

  alias Re.Addresses.Neighborhoods

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

  describe "get_description" do
    test "should return neighborhood description according to address" do
      address = insert(:address, city: "Rio de Janeiro", state: "RJ", neighborhood: "Botafogo")

      insert(:neighborhood_description,
        city: "Rio de Janeiro",
        state: "RJ",
        neighborhood: "Botafogo",
        description: "descr"
      )

      {:ok, neighborhood_description} = Neighborhoods.get_description(address)
      assert neighborhood_description.city == "Rio de Janeiro"
      assert neighborhood_description.state == "RJ"
      assert neighborhood_description.neighborhood == "Botafogo"
      assert neighborhood_description.description == "descr"
    end

    test "should not return neighborhood description according to address if does not match" do
      address = insert(:address, city: "Rio de Janeiro", state: "RJ", neighborhood: "Botafogo")

      insert(:neighborhood_description,
        city: "Rio de Janeiro",
        state: "RJ",
        neighborhood: "Flamengo",
        description: "descr"
      )

      assert {:error, :not_found} == Neighborhoods.get_description(address)
    end
  end
end
