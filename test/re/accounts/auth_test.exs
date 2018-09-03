defmodule Re.Accounts.AuthTest do
  use Re.ModelCase

  alias Re.{
    Accounts.Auth,
    Repo,
    User
  }

  import Re.Factory

  describe "account_kit_sign_in/1" do
    test "should sign in with access token for new user" do
      {:ok, user} = Auth.account_kit_sign_in("valid_access_token")

      assert user = Repo.get(User, user.id)
      assert "321" == user.account_kit_id
      assert "+5511999999999" == user.phone
    end

    test "should sign in with access token for existing user" do
      insert(:user, account_kit_id: "321", phone: "+5511999999999")
      {:ok, user} = Auth.account_kit_sign_in("valid_access_token")

      assert user = Repo.get(User, user.id)
      assert "321" == user.account_kit_id
      assert "+5511999999999" == user.phone
    end

    test "should not sign in with invalid access token" do
      {:error, payload} = Auth.account_kit_sign_in("invalid_access_token")

      assert payload == %{"message" => "Invalid access token"}
    end
  end
end
