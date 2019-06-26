defmodule Re.Addresses.DistrictTest do
  use Re.ModelCase

  alias Re.{
    Addresses.District,
    Repo
  }

  import Re.Factory

  @valid_attrs %{
    state: "RJ",
    city: "Rio de Janeiro",
    name: "Botafogo",
    description: "loren ipsun"
  }
  @invalid_attrs %{
    state: "RJ",
    city: "Rio de Janeiro",
    name: "Botafogo",
    description: "loren ipsun",
    status: "invalid state"
  }

  test "changeset with valid attributes" do
    changeset = District.changeset(%District{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = District.changeset(%District{}, @invalid_attrs)
    refute changeset.valid?

    assert Keyword.get(changeset.errors, :status) ==
             {"is invalid", [validation: :inclusion, enum: ~w(covered partially_covered uncovered)]}
  end
end
