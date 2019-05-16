defmodule Re.Developments.ListingsTest do
  use Re.ModelCase

  alias Re.{
    Development,
    Developments
  }

  import Re.Factory

  describe "insert/2" do
    @insert_development_listing_params %{
      "type" => "Apartamento",
      "has_elevator" => true,
      "description" => "Awesome new brand building",
      "is_exportable" => true
    }

    test "should insert development listing" do
      address = insert(:address)
      development = insert(:development, address_id: address.id)
      user = insert(:user, role: "admin")

      assert {:ok, inserted_listing} =
               Listings.insert(@insert_development_listing_params,
                 address: address,
                 user: user,
                 development: development
               )

      assert retrieved_listing = Repo.get(Listing, inserted_listing.id)
      assert retrieved_listing.development_uuid == development.uuid
      assert retrieved_listing.address_id == address.id
      assert retrieved_listing.user_id == user.id
      assert retrieved_listing.is_exportable == true
      assert retrieved_listing.uuid
    end

    test "should copy infrastructure info from development" do
      address = insert(:address)
      development = insert(:development, address_id: address.id)
      user = insert(:user, role: "admin")

      assert {:ok, inserted_listing} =
               Listings.insert(@insert_development_listing_params,
                 address: address,
                 user: user,
                 development: development
               )

      assert retrieved_listing = Repo.get(Listing, inserted_listing.id)
      assert retrieved_listing.development_uuid == development.uuid
      assert retrieved_listing.floor_count == development.floor_count
      assert retrieved_listing.unit_per_floor == development.units_per_floor
      assert retrieved_listing.elevators == development.elevators
    end
  end

  describe "update/3" do
    test "should update development with new params" do
      address = insert(:address)
      development = insert(:development, address: address)

      new_development_params = params_for(:development)
      new_address = insert(:address)

      Developments.update(development, new_development_params, new_address)

      updated_development = Repo.get(Development, development.uuid)
      assert updated_development.address_id == new_address.id
      assert updated_development.name == Map.get(new_development_params, :name)
      assert updated_development.builder == Map.get(new_development_params, :builder)
      assert updated_development.description == Map.get(new_development_params, :description)
      assert updated_development.phase == Map.get(new_development_params, :phase)
    end
  end
end
