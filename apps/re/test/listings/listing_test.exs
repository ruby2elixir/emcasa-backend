defmodule Re.ListingTest do
  use Re.ModelCase

  alias Re.Listing

  import Re.Factory

  @valid_attrs %{
    type: "Apartamento",
    complement: "100",
    description: "some content",
    price: 1_000_000,
    property_tax: 500.00,
    maintenance_fee: 300.00,
    floor: "3",
    rooms: 4,
    bathrooms: 4,
    restrooms: 4,
    suites: 1,
    dependencies: 1,
    balconies: 1,
    has_elevator: true,
    area: 150,
    garage_spots: 2,
    garage_type: "contract",
    score: 4,
    matterport_code: "",
    is_exclusive: false,
    is_release: false,
    is_exportable: true
  }
  @invalid_attrs %{
    type: "ApartmentApartmentApartmentApartmentApartment",
    complement: "complementcomplementcomplementcomplement",
    price: -1,
    property_tax: -500.00,
    maintenance_fee: -300.00,
    bathrooms: -1,
    restrooms: -1,
    suites: -1,
    dependencies: -1,
    balconies: -1,
    garage_spots: -1,
    garage_type: "mine",
    score: 5,
    is_exclusive: "banana",
    is_release: "banana",
    is_exportable: "banana"
  }

  describe "user" do
    test "changeset with valid attributes" do
      address = insert(:address)
      user = insert(:user)

      attrs =
        @valid_attrs
        |> Map.put(:address_id, address.id)
        |> Map.put(:user_id, user.id)

      changeset = Listing.changeset(%Listing{}, attrs, "user")
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Listing.changeset(%Listing{}, @invalid_attrs, "user")
      refute changeset.valid?

      assert Keyword.get(changeset.errors, :type) ==
               {"should be one of: [Apartamento Casa Cobertura]", [validation: :inclusion]}

      assert Keyword.get(changeset.errors, :property_tax) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :maintenance_fee) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :bathrooms) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :restrooms) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :suites) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :dependencies) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :balconies) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :garage_spots) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :garage_type) ==
               {"should be one of: [contract condominium]", [validation: :inclusion]}

      assert Keyword.get(changeset.errors, :is_exclusive) ==
               {"is invalid", [type: :boolean, validation: :cast]}

      assert Keyword.get(changeset.errors, :is_release) ==
               {"is invalid", [type: :boolean, validation: :cast]}
    end
  end

  describe "admin" do
    test "changeset with valid attributes" do
      address = insert(:address)
      user = insert(:user)

      attrs =
        @valid_attrs
        |> Map.put(:address_id, address.id)
        |> Map.put(:user_id, user.id)

      changeset = Listing.changeset(%Listing{}, attrs, "admin")
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Listing.changeset(%Listing{}, @invalid_attrs, "admin")
      refute changeset.valid?

      assert Keyword.get(changeset.errors, :type) ==
               {"should be one of: [Apartamento Casa Cobertura]", [validation: :inclusion]}

      assert Keyword.get(changeset.errors, :score) ==
               {"must be less than %{number}", [validation: :number, kind: :less_than, number: 5]}

      assert Keyword.get(changeset.errors, :price) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 250_000]}

      assert Keyword.get(changeset.errors, :property_tax) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :maintenance_fee) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :bathrooms) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :restrooms) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :suites) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :dependencies) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :balconies) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :garage_spots) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :is_exclusive) ==
               {"is invalid", [type: :boolean, validation: :cast]}

      assert Keyword.get(changeset.errors, :is_release) ==
               {"is invalid", [type: :boolean, validation: :cast]}

      assert Keyword.get(changeset.errors, :is_exportable) ==
               {"is invalid", [type: :boolean, validation: :cast]}

      changeset = Listing.changeset(%Listing{}, %{score: 0, price: 110_000_000}, "admin")
      refute changeset.valid?

      assert Keyword.get(changeset.errors, :score) ==
               {"must be greater than %{number}",
                [validation: :number, kind: :greater_than, number: 0]}

      assert Keyword.get(changeset.errors, :price) ==
               {"must be less than or equal to %{number}",
                [validation: :number, kind: :less_than_or_equal_to, number: 100_000_000]}
    end
  end
end
