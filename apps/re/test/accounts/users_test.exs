defmodule Re.Accounts.UsersTest do
  use Re.ModelCase

  alias Re.{
    Accounts.Users
  }

  import Re.Factory

  describe "update/3" do
    test "should update a without options" do
      user = insert(:user, role: "user")

      update_param = %{email: "a@a.com", name:  "Xurupita", role: "admin"}
      assert {:ok, user} = Users.update(user, update_param)
      assert update_param.email == user.email
      assert update_param.name == user.name
      assert update_param.role == user.role
    end

    test "should update a with district as option" do
      user = insert(:user, role: "user")
      districts = insert_list(2, :district)
      districts_param = Enum.map(districts, fn district -> district.name_slug end)

      update_param = %{email: "a@a.com", name:  "Xurupita", role: "admin"}

      assert {:ok, user} = Users.update(user, update_param, districts: districts_param)
      assert update_param.email == user.email
      assert update_param.name == user.name
      assert update_param.role == user.role
      assert districts == user.districts
    end
  end
end
