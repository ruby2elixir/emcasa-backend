defmodule Re.OwnerContactTest do
  use Re.ModelCase

  alias Re.OwnerContact

  test "changeset with valid attributes" do
    params = %{name: "Mr Marvel", phone: "+33983721209", email: "mr@marvel.com"}

    changeset = OwnerContact.changeset(%OwnerContact{}, params)

    assert changeset.valid?
    assert changeset.changes.name_slug == "mr-marvel"
    assert changeset.changes.uuid != nil
  end

  test "chagenset with empty email" do
    params = %{name: "Mr Marvel", phone: "+33983721209"}

    changeset = OwnerContact.changeset(%OwnerContact{}, params)

    assert changeset.valid?
    assert changeset.changes.name_slug == "mr-marvel"
    assert changeset.changes.uuid != nil
  end

  test "changeset with invalid attributes" do
    params = %{name: 123, phone: 876_543_526, email: "invalidone"}

    changeset = OwnerContact.changeset(%OwnerContact{}, params)

    refute changeset.valid?

    assert Keyword.get(changeset.errors, :name) ==
             {"is invalid", [type: :string, validation: :cast]}

    assert Keyword.get(changeset.errors, :phone) ==
             {"is invalid", [type: :string, validation: :cast]}

    assert Keyword.get(changeset.errors, :email) == {"has invalid format", [validation: :format]}
  end

  test "changeset with missing attributes" do
    params = %{}

    changeset = OwnerContact.changeset(%OwnerContact{}, params)

    refute changeset.valid?
    assert Keyword.get(changeset.errors, :name) == {"can't be blank", [validation: :required]}
    assert Keyword.get(changeset.errors, :phone) == {"can't be blank", [validation: :required]}
  end
end
