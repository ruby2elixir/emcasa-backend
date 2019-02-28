defmodule Re.DevelopmentTest do
  use Re.ModelCase

  alias Re.Development

  import Re.Factory

  @invalid_attrs %{
    name: "",
    title: "",
    phase: "unexpected",
    builder: "",
    description: ""
  }

  @valid_attrs %{
    name: "Em casa development",
    title: "Em casa - living in your dream",
    phase: "pre-launch",
    builder: "EmCasa",
    description: "description"
  }

  test "changeset with valid attributes" do
    %{id: address_id} = insert(:address)

    attrs =
      @valid_attrs
      |> Map.put(:address_id, address_id)

    changeset = Development.changeset(%Development{}, attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Development.changeset(%Development{}, @invalid_attrs)
    refute changeset.valid?

    assert Keyword.get(changeset.errors, :phase) ==
             {"should be one of: [pre-launch planning building delivered]",
              [validation: :inclusion]}

    assert Keyword.get(changeset.errors, :name) == {"can't be blank", [validation: :required]}

    assert Keyword.get(changeset.errors, :title) == {"can't be blank", [validation: :required]}

    assert Keyword.get(changeset.errors, :builder) == {"can't be blank", [validation: :required]}

    assert Keyword.get(changeset.errors, :address_id) ==
             {"can't be blank", [validation: :required]}
  end
end
