defmodule Re.Accounts.AccountsTest do
  use Re.ModelCase

  alias Re.{
    Accounts,
    Repo,
    User
  }

  import Re.Factory

  describe "change_role/2" do
    test "should make a common user an admin" do
      %{uuid: uuid} = user = insert(:user, role: "user")

      assert {:ok, _user} = Accounts.change_role(user, "admin")

      assert user = Repo.get_by(User, uuid: uuid)
      assert "admin" == user.role
    end

    test "should make an admin a common user" do
      %{uuid: uuid} = user = insert(:user) |> make_admin()

      assert {:ok, _user} = Accounts.change_role(user, "user")

      assert user = Repo.get_by(User, uuid: uuid)
      assert "user" == user.role
    end
  end
end
