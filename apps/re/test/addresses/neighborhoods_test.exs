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
      insert(:listing, address: address2, status: "inactive")

      assert ["Test 1"] == Neighborhoods.all()
    end
  end

  describe "get_description" do
    test "should return neighborhood description according to address" do
      address = insert(:address, city: "Rio de Janeiro", state: "RJ", neighborhood: "Lapa")

      insert(:district,
        city: "Rio de Janeiro",
        state: "RJ",
        name: "Lapa",
        description: "descr"
      )

      {:ok, district} = Neighborhoods.get_description(address)
      assert district.city == "Rio de Janeiro"
      assert district.state == "RJ"
      assert district.name == "Lapa"
      assert district.description == "descr"
    end

    test "should not return neighborhood description according to address if does not match" do
      address = insert(:address, city: "Rio de Janeiro", state: "RJ", neighborhood: "Lapa")

      insert(:district,
        city: "Rio de Janeiro",
        state: "RJ",
        name: "Centro",
        description: "descr"
      )

      assert {:error, :not_found} == Neighborhoods.get_description(address)
    end
  end

  describe "is_covered/1" do
    test "should be true when neighborhood exists" do
      neighborhood = %{state: "RJ", neighborhood: "Humaitá", city: "Rio de Janeiro"}
      assert Neighborhoods.is_covered(neighborhood)
    end

    test "should be true when neighborhood exists without consider accents" do
      neighborhood = %{state: "RJ", neighborhood: "Humaita", city: "Rio de Janeiro"}
      assert Neighborhoods.is_covered(neighborhood)
    end

    test "should be true when neighborhood exists and without consider case" do
      neighborhood = %{state: "RJ", neighborhood: "humaitá", city: "Rio de Janeiro"}
      assert Neighborhoods.is_covered(neighborhood)
    end

    test "should be false when neighborhood does not exists" do
      neighborhood = %{state: "RJ", neighborhood: "Lapa", city: "Rio de Janeiro"}
      refute Neighborhoods.is_covered(neighborhood)
    end

    test "should be false when city does not exists" do
      neighborhood = %{state: "RS", neighborhood: "Humaitá", city: "Rio de Janeiro"}
      refute Neighborhoods.is_covered(neighborhood)
    end

    test "should be false when state does not exists" do
      neighborhood = %{state: "RJ", neighborhood: "Humaitá", city: "Porto Alegre"}
      refute Neighborhoods.is_covered(neighborhood)
    end
  end
end
