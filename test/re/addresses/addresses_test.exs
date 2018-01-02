defmodule Re.AddressesTest do
  use Re.ModelCase

  alias Re.{
    Address,
    Addresses
  }

  import Re.Factory

  test "should do nothing when there's no change" do
    address = insert(:address)
    listing = insert(:listing, address: address)
    address_params =
      address
      |> Map.from_struct()
      |> Map.delete(:__meta__)
      |> stringify_keys()
    assert address.id == Addresses.update(listing, address_params).id
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

  defp stringify_keys(map = %{}) do
    map
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
    |> Enum.into(%{})
  end
end
