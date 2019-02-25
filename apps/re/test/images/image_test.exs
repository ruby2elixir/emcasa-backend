defmodule Re.ImageTest do
  use Re.ModelCase

  alias Re.Image

  import Re.Factory

  @valid_attrs %{
    filename: "my_picture.jpg",
    position: 1,
    description: "Home sweet home"
  }

  @invalid_attrs %{
    filename: ""
  }

  describe "create_changeset" do
    test "should be valid with listing assoc" do
      listing_params = params_for(:listing)
      attrs = Map.put(@valid_attrs, :listing, listing_params)
      changeset = Image.create_changeset(%Image{}, attrs)

      assert changeset.valid?
    end

    test "should be valid with development assoc" do
      development_params = params_for(:development)
      attrs = Map.put(@valid_attrs, :development, development_params)
      changeset = Image.create_changeset(%Image{}, attrs)

      assert changeset.valid?
    end

    test "should be invalid" do
      changeset = Image.create_changeset(%Image{}, @invalid_attrs)
      refute changeset.valid?

      assert Keyword.get(changeset.errors, :filename) ==
               {"can't be blank", [validation: :required]}
    end
  end
end
