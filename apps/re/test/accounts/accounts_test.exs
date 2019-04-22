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
      %{id: id} = insert(:user, account_kit_id: "321", phone: "+5511999999999")

      {:ok, user} = Accounts.promote_user_to_admin("+5511999999999")

      assert user = Repo.get(User, id)
      assert "admin" == user.role
    end

    test "should error when user doesn't exist" do
      {:error, :not_found} = Accounts.promote_user_to_admin("+5511999999999")
    end
  end
end
