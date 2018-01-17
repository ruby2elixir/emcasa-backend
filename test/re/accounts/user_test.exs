defmodule Re.UserTest do
  use Re.ModelCase

  alias Re.{
    Repo,
    User
  }

  import Re.Factory

  @valid_attrs %{
    name: "mahname",
    email: "validemail@emcasa.com",
    phone: "317894719384",
    password: "validpassword",
    role: "user"
  }
  @invalid_attrs %{
    name: nil,
    email: "invalidemail",
    password: "",
    role: "inexisting role"
  }

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
    assert Keyword.get(changeset.errors, :name) == {"can't be blank", [validation: :required]}
    assert Keyword.get(changeset.errors, :email) == {"has invalid format", [validation: :format]}
    assert Keyword.get(changeset.errors, :password) == {"can't be blank", [validation: :required]}
    assert Keyword.get(changeset.errors, :role) == {"should be one of: [admin user]", [validation: :inclusion]}
  end

  test "duplicated email should be invalid" do
    insert(:user, @valid_attrs)
    {:error, changeset} =
      %User{}
      |> User.changeset(@valid_attrs)
      |> Repo.insert()

    assert changeset.errors == [email: {"has already been taken", []}]
  end
end
