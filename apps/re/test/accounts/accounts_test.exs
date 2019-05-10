defmodule Re.Accounts.AccountsTest do
  use Re.ModelCase

  alias Re.{
    Accounts,
    Repo,
    User
  }

  import Re.Factory

  describe "promote_user_to_admin/1" do
    test "should promote user to admin" do
      %{uuid: uuid} = user = insert(:user)

      assert {:ok, _user} = Accounts.promote_user_to_admin(user)

      assert user = Repo.get_by(User, uuid: uuid)
      assert "admin" == user.role
    end
  end
end
