defmodule Re.AddressesTest do
  use Re.ModelCase

  alias Re.Addresses

  import Re.Factory

  test "update should do nothing when there's no change" do
    address = insert(:address)
    listing = insert(:listing, address: address)
    address_params = Map.from_struct(address) |> Map.delete(:__meta__) |> stringify_keys()
    assert address.id == Addresses.update(listing, address_params)
  end

  defp stringify_keys(map = %{}) do
    map
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
    |> Enum.into(%{})
  end
end
