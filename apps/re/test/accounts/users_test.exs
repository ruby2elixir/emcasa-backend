defmodule Re.Accounts.UsersTest do
  use Re.ModelCase

  alias Re.{
    Accounts.Users
  }

  import Re.Factory

  describe "update/3" do
    test "should update a without options" do
      user = insert(:user, role: "user")

      update_param = %{email: "a@a.com", name: "Xurupita", role: "admin"}
      assert {:ok, user} = Users.update(user, update_param)
      assert update_param.email == user.email
      assert update_param.name == user.name
      assert update_param.role == user.role
    end
  end
end
