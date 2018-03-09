defmodule Re.AddressTest do
  use Re.ModelCase

  alias Re.{
    Address,
    Repo
  }

  import Re.Factory

  @valid_attrs %{
    street: "some street",
    street_number: "65",
    neighborhood: "downtown",
    city: "Rio de Janeiro",
    state: "RJ",
    postal_code: "22020-001",
    lat: 55.3213,
    lng: 110.01
  }
  @invalid_attrs %{
    street: String.duplicate("some street", 15),
    street_number: String.duplicate("125", 50),
    neighborhood: String.duplicate("downtown", 30),
    city: String.duplicate("Rio de Janeiro", 20),
    state: "RJJ",
    lat: -95,
    lng: -200
  }

  test "changeset with valid attributes" do
    changeset = Address.changeset(%Address{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Address.changeset(%Address{}, @invalid_attrs)
    refute changeset.valid?

    assert Keyword.get(changeset.errors, :street) ==
             {"should be at most %{count} character(s)",
              [count: 128, validation: :length, max: 128]}

    assert Keyword.get(changeset.errors, :street_number) ==
             {"should be at most %{count} character(s)",
              [count: 128, validation: :length, max: 128]}

    assert Keyword.get(changeset.errors, :neighborhood) ==
             {"should be at most %{count} character(s)",
              [count: 128, validation: :length, max: 128]}

    assert Keyword.get(changeset.errors, :city) ==
             {"should be at most %{count} character(s)",
              [count: 128, validation: :length, max: 128]}

    assert Keyword.get(changeset.errors, :state) ==
             {"should be %{count} character(s)", [count: 2, validation: :length, is: 2]}

    assert Keyword.get(changeset.errors, :lat) == {"invalid latitude", []}
    assert Keyword.get(changeset.errors, :lng) == {"invalid longitude", []}
  end

  test "duplicated address should be invalid" do
    insert(:address, @valid_attrs)

    {:error, changeset} =
      %Address{}
      |> Address.changeset(@valid_attrs)
      |> Repo.insert()

    assert changeset.errors == [postal_code: {"has already been taken", []}]
  end

  test "five digits posta code should be valid" do
    attr = Map.put(@valid_attrs, :postal_code, "22041")
    changeset = Address.changeset(%Address{}, attr)
    assert changeset.valid?
  end
end
