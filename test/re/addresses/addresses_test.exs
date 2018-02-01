defmodule Re.AddressesTest do
  use Re.ModelCase

  alias Re.{
    Addresses
  }

  import Re.Factory

  describe "update" do
    test "should do nothing when there's no change" do
      address = insert(:address)
      listing = insert(:listing, address: address)

      address_params =
        address
        |> Map.from_struct()
        |> Map.delete(:__meta__)
        |> stringify_keys()

      assert {:ok, address} == Addresses.update(listing, address_params)
    end

    test "should update address attributes" do
      address = insert(:address)
      listing = insert(:listing, address: address)

      address_params =
        address
        |> Map.from_struct()
        |> Map.put(:street, "new street name")
        |> Map.put(:street_number, "55")
        |> Map.put(:postal_code, "54321-876")
        |> Map.delete(:__meta__)
        |> stringify_keys()

      {:ok, updated_address} = Addresses.update(listing, address_params)

      assert updated_address.street == "new street name"
      assert updated_address.street_number == "55"
      assert updated_address.postal_code == "54321-876"
    end
  end

  describe "find_or_create" do
    test "create new address" do
      {:ok, created_address} =
        Addresses.find_or_create(%{
          "street" => "test st",
          "street_number" => "101",
          "neighborhood" => "downtown",
          "city" => "neverland",
          "state" => "ST",
          "postal_code" => "11111-111",
          "lat" => "-1",
          "lng" => "1"
        })

      assert created_address.id
      assert created_address.street == "test st"
      assert created_address.street_number == "101"
      assert created_address.neighborhood == "downtown"
      assert created_address.city == "neverland"
      assert created_address.state == "ST"
      assert created_address.postal_code == "11111-111"
      assert created_address.lat == -1.0
      assert created_address.lng == 1.0
    end

    test "find address" do
      address = insert(:address)

      {:ok, created_address} =
        Addresses.find_or_create(%{
          "street" => address.street,
          "street_number" => address.street_number,
          "neighborhood" => address.neighborhood,
          "city" => address.city,
          "state" => address.state,
          "postal_code" => address.postal_code,
          "lat" => address.lat,
          "lng" => address.lng
        })

      assert created_address.id == address.id
      assert created_address.street == address.street
      assert created_address.street_number == address.street_number
      assert created_address.neighborhood == address.neighborhood
      assert created_address.city == address.city
      assert created_address.state == address.state
      assert created_address.postal_code == address.postal_code
      assert created_address.lat == address.lat
      assert created_address.lng == address.lng
    end
  end

  defp stringify_keys(map = %{}) do
    map
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
    |> Enum.into(%{})
  end
end
