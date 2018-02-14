defmodule Re.ListingTest do
  use Re.ModelCase

  alias Re.Listing

  import Re.Factory

  @valid_attrs %{
    type: "Apartamento",
    complement: "100",
    description: "some content",
    price: 1_000_000,
    floor: "3",
    rooms: 4,
    bathrooms: 4,
    area: 150,
    garage_spots: 2,
    score: 4,
    matterport_code: "",
    is_exclusive: false
  }
  @invalid_attrs %{
    type: "ApartmentApartmentApartmentApartmentApartment",
    complement: "complementcomplementcomplementcomplement",
    price: -1,
    bathrooms: -1,
    garage_spots: -1,
    score: 5,
    is_exclusive: "banana"
  }

  test "changeset with valid attributes" do
    address = insert(:address)
    user = insert(:user)

    attrs =
      @valid_attrs
      |> Map.put(:address_id, address.id)
      |> Map.put(:user_id, user.id)

    changeset = Listing.changeset(%Listing{}, attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Listing.changeset(%Listing{}, @invalid_attrs)
    refute changeset.valid?

    assert Keyword.get(changeset.errors, :type) ==
             {"should be one of: [Apartamento Casa Cobertura]", [validation: :inclusion]}

    assert Keyword.get(changeset.errors, :score) ==
             {"must be less than %{number}", [validation: :number, number: 5]}

    assert Keyword.get(changeset.errors, :price) ==
             {"must be greater than or equal to %{number}", [validation: :number, number: 0]}

    assert Keyword.get(changeset.errors, :bathrooms) ==
             {"must be greater than or equal to %{number}", [validation: :number, number: 0]}

    assert Keyword.get(changeset.errors, :garage_spots) ==
             {"must be greater than or equal to %{number}", [validation: :number, number: 0]}

    assert Keyword.get(changeset.errors, :address_id) ==
             {"can't be blank", [validation: :required]}

    assert Keyword.get(changeset.errors, :is_exclusive) ==
             {"is invalid", [type: :boolean, validation: :cast]}

    changeset = Listing.changeset(%Listing{}, %{score: 0})
    refute changeset.valid?

    assert Keyword.get(changeset.errors, :score) ==
             {"must be greater than %{number}", [validation: :number, number: 0]}
  end
end
