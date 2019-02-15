defmodule Re.Tasks.Re.Addresses.PadRightPostalCodeWithZeros do
  use Re.ModelCase

  alias Re.{
    Address,
    Listing,
    Repo
  }

  import Re.Factory

  describe "when address already exists" do
    test "should point listing replace address no listing" do
      params = params_for(:address, postal_code: "99999-000")
      invalid_params = Map.merge(params, %{postal_code: "99999"})

      %{id: valid_address_id} = insert(:address, params)
      %{id: invalid_address_id} = insert(:address, invalid_params)

      %{id: listing_id} = insert(:listing, address_id: invalid_address_id)

      Mix.Tasks.Re.FixInvalidPostalCodes.run(nil)

      listing = Repo.get(Listing, listing_id)

      %{listings: [%{id: returned_listing_id}]} =
        Repo.get(Address, valid_address_id)
        |> Repo.preload(:listings)

      assert [listing_id] == [returned_listing_id]
      assert valid_address_id == listing.address_id
    end

    test "should remove the listing from invalid address" do
      params = params_for(:address, postal_code: "99999-000")
      invalid_params = Map.merge(params, %{postal_code: "99999"})

      insert(:address, params)
      %{id: invalid_address_id} = insert(:address, invalid_params)

      insert(:listing, address_id: invalid_address_id)

      Mix.Tasks.Re.FixInvalidPostalCodes.run(nil)

      invalid_address =
        Repo.get(Address, invalid_address_id)
        |> Repo.preload(:listings)

      assert [] == invalid_address.listings
    end
  end

  describe "address does not exists" do
    test "update current address" do
      %{id: address_id} = insert(:address, postal_code: "99999")
      insert(:listing, address_id: address_id)

      Mix.Tasks.Re.FixInvalidPostalCodes.run(nil)

      updated_address = Repo.get(Address, address_id)
      assert updated_address.postal_code == "99999-000"
    end
  end
end
