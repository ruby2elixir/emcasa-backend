defmodule ReWeb.GraphQL.Accounts.MutationTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers
  alias Re.User
  alias Comeonin.Bcrypt

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_user: admin_user,
     user_user: user_user,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  describe "activateListing" do
    test "admin should get favorited listings", %{admin_conn: conn, admin_user: user} do
      listing = insert(:listing)
      insert(:listings_favorites, listing_id: listing.id, user_id: user.id)

      query = """
        query FavoritedListings {
          favoritedListings {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      listing_id = to_string(listing.id)
      assert [%{"id" => listing_id}] == json_response(conn, 200)["data"]["favoritedListings"]
    end

    test "user should get favorited listings", %{user_conn: conn, user_user: user} do
      listing = insert(:listing)
      insert(:listings_favorites, listing_id: listing.id, user_id: user.id)

      query = """
        query FavoritedListings {
          favoritedListings {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      listing_id = to_string(listing.id)
      assert [%{"id" => listing_id}] == json_response(conn, 200)["data"]["favoritedListings"]
    end

    test "anonymous should not get favorited listing", %{unauthenticated_conn: conn} do
      query = """
        query FavoritedListings {
          favoritedListings {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      [errors] = json_response(conn, 200)["errors"]

      assert errors["message"] == "Unauthorized"
      assert errors["code"] == 401
    end
  end

  describe "editUserProfile" do
    test "admin should edit any profile", %{admin_conn: conn, user_user: user} do
      variables = %{
        "id" => user.id,
        "name" => "Fixed Name",
        "phone" => "123321123",
        "notificationPreferences" => %{
          "email" => false,
          "app" => false
        },
        "deviceToken" => "asdasdasd"
      }

      mutation = """
        mutation EditUserProfile($id: ID!, $name: String, $phone: String, $notificationPreferences: NotificationPreferencesInput, $deviceToken: String) {
          editUserProfile(
            id: $id,
            name: $name,
            phone: $phone,
            notificationPreferences: $notificationPreferences,
            deviceToken: $deviceToken
          ){
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{"id" => to_string(user.id)} == json_response(conn, 200)["data"]["editUserProfile"]

      assert user = Repo.get(User, user.id)
      assert user.name == "Fixed Name"
      assert user.phone == "123321123"
      assert user.device_token == "asdasdasd"
      refute user.notification_preferences.email
      refute user.notification_preferences.app
    end

    test "user should edit own profile", %{user_conn: conn, user_user: user} do
      variables = %{
        "id" => user.id,
        "name" => "Fixed Name",
        "phone" => "123321123",
        "notificationPreferences" => %{
          "email" => false,
          "app" => false
        },
        "deviceToken" => "asdasdasd"
      }

      mutation = """
        mutation EditUserProfile($id: ID!, $name: String, $phone: String, $notificationPreferences: NotificationPreferencesInput, $deviceToken: String) {
          editUserProfile(
            id: $id,
            name: $name,
            phone: $phone,
            notificationPreferences: $notificationPreferences,
            deviceToken: $deviceToken
          ){
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{"id" => to_string(user.id)} == json_response(conn, 200)["data"]["editUserProfile"]

      assert user = Repo.get(User, user.id)
      assert user.name == "Fixed Name"
      assert user.phone == "123321123"
      assert user.device_token == "asdasdasd"
      refute user.notification_preferences.email
      refute user.notification_preferences.app
    end

    test "user should not edit other user's  profile", %{user_conn: conn} do
      inserted_user = insert(:user)

      variables = %{
        "id" => inserted_user.id,
        "name" => "Fixed Name"
      }

      mutation = """
        mutation EditUserProfile($id: ID!, $name: String) {
          editUserProfile(id: $id, name: $name) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not edit user profile", %{unauthenticated_conn: conn} do
      user = insert(:user)

      variables = %{
        "id" => user.id,
        "name" => "Fixed Name"
      }

      mutation = """
        mutation EditUserProfile($id: ID!, $name: String) {
          editUserProfile(id: $id, name: $name) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end
  end

  describe "changeEmail" do
    test "admin should change email", %{admin_conn: conn} do
      user = insert(:user, email: "old_email@emcasa.com")

      variables = %{
        "id" => user.id,
        "email" => "newemail@emcasa.com"
      }

      mutation = """
        mutation ChangeEmail($id: ID!, $email: String) {
          changeEmail(id: $id, email: $email) {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert user = Repo.get(User, user.id)
      assert user.email == "newemail@emcasa.com"
    end

    test "user should change own email", %{user_conn: conn, user_user: user} do
      variables = %{
        "id" => user.id,
        "email" => "newemail@emcasa.com"
      }

      mutation = """
        mutation ChangeEmail($id: ID!, $email: String) {
          changeEmail(id: $id, email: $email) {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert user = Repo.get(User, user.id)
      assert user.email == "newemail@emcasa.com"
    end

    test "user should not edit other user's  email", %{user_conn: conn} do
      inserted_user = insert(:user)

      variables = %{
        "id" => inserted_user.id,
        "email" => "newemail@emcasa.com"
      }

      mutation = """
        mutation ChangeEmail($id: ID!, $email: String) {
          changeEmail(id: $id, email: $email) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not edit user profile", %{unauthenticated_conn: conn} do
      user = insert(:user)

      variables = %{
        "id" => user.id,
        "email" => "newemail@emcasa.com"
      }

      mutation = """
        mutation ChangeEmail($id: ID!, $email: String) {
          changeEmail(id: $id, email: $email) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end

    test "should fail when using existing e-mail", %{user_conn: conn, user_user: user} do
      insert(:user, email: "existing@emcasa.com")

      variables = %{
        "id" => user.id,
        "email" => "existing@emcasa.com"
      }

      mutation = """
        mutation ChangeEmail($id: ID!, $email: String) {
          changeEmail(id: $id, email: $email) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "email has already been taken"}] = json_response(conn, 200)["errors"]
    end
  end

  describe "changePassword" do
    test "admin should change password", %{admin_conn: conn} do
      user = insert(:user)

      variables = %{
        "id" => user.id,
        "currentPassword" => "password",
        "newPassword" => "newpass"
      }

      mutation = """
        mutation ChangePassword($id: ID!, $currentPassword: String, $newPassword: String) {
          changePassword(id: $id, currentPassword: $currentPassword, newPassword: $newPassword) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{"id" => to_string(user.id)} == json_response(conn, 200)["data"]["changePassword"]

      assert user = Repo.get(User, user.id)
      assert Bcrypt.checkpw("newpass", user.password_hash)
    end

    test "user should change own email", %{user_conn: conn, user_user: user} do
      variables = %{
        "id" => user.id,
        "currentPassword" => "password",
        "newPassword" => "newpass"
      }

      mutation = """
        mutation ChangePassword($id: ID!, $currentPassword: String, $newPassword: String) {
          changePassword(id: $id, currentPassword: $currentPassword, newPassword: $newPassword) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{"id" => to_string(user.id)} == json_response(conn, 200)["data"]["changePassword"]

      assert user = Repo.get(User, user.id)
      assert Bcrypt.checkpw("newpass", user.password_hash)
    end

    test "user should not edit other user's  email", %{user_conn: conn} do
      inserted_user = insert(:user)

      variables = %{
        "id" => inserted_user.id,
        "currentPassword" => "password",
        "newPassword" => "newpass"
      }

      mutation = """
        mutation ChangePassword($id: ID!, $currentPassword: String, $newPassword: String) {
          changePassword(id: $id, currentPassword: $currentPassword, newPassword: $newPassword) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not edit user profile", %{unauthenticated_conn: conn} do
      user = insert(:user)

      variables = %{
        "id" => user.id,
        "currentPassword" => "password",
        "newPassword" => "newpass"
      }

      mutation = """
        mutation ChangePassword($id: ID!, $currentPassword: String, $newPassword: String) {
          changePassword(id: $id, currentPassword: $currentPassword, newPassword: $newPassword) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end
  end

  describe "signIn" do
    test "should sign in as admin", %{unauthenticated_conn: conn} do
      user =
        insert(:user,
          role: "admin",
          email: "admin@emcasa.com",
          password_hash: Bcrypt.hashpwsalt("password")
        )

      variables = %{
        "email" => "admin@emcasa.com",
        "password" => "password"
      }

      mutation = """
        mutation SignIn($email: String!, $password: String!) {
          signIn(email: $email, password: $password) {
            jwt
            user {
              id
              name
              email
              phone
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "id" => to_string(user.id),
               "name" => user.name,
               "email" => user.email,
               "phone" => user.phone
             } == json_response(conn, 200)["data"]["signIn"]["user"]

      assert json_response(conn, 200)["data"]["signIn"]["jwt"]
    end

    test "should sign in as user", %{unauthenticated_conn: conn} do
      user =
        insert(:user,
          role: "user",
          email: "user@emcasa.com",
          password_hash: Bcrypt.hashpwsalt("password")
        )

      variables = %{
        "email" => "user@emcasa.com",
        "password" => "password"
      }

      mutation = """
        mutation SignIn($email: String!, $password: String!) {
          signIn(email: $email, password: $password) {
            jwt
            user {
              id
              name
              email
              phone
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "id" => to_string(user.id),
               "name" => user.name,
               "email" => user.email,
               "phone" => user.phone
             } == json_response(conn, 200)["data"]["signIn"]["user"]

      assert json_response(conn, 200)["data"]["signIn"]["jwt"]
    end

    test "should not sign in on wrong e-mail", %{unauthenticated_conn: conn} do
      insert(:user,
        role: "user",
        email: "user@emcasa.com",
        password_hash: Bcrypt.hashpwsalt("password")
      )

      variables = %{
        "email" => "wrongemail@emcasa.com",
        "password" => "password"
      }

      mutation = """
        mutation SignIn($email: String!, $password: String!) {
          signIn(email: $email, password: $password) {
            jwt
            user {
              id
              name
              email
              phone
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end

    test "should not sign in on wrong password", %{unauthenticated_conn: conn} do
      insert(:user,
        role: "user",
        email: "user@emcasa.com",
        password_hash: Bcrypt.hashpwsalt("password")
      )

      variables = %{
        "email" => "user@emcasa.com",
        "password" => "wrongpass"
      }

      mutation = """
        mutation SignIn($email: String!, $password: String!) {
          signIn(email: $email, password: $password) {
            jwt
            user {
              id
              name
              email
              phone
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end
  end

  describe "register" do
    test "should register user", %{unauthenticated_conn: conn} do
      variables = %{
        "name" => "name",
        "phone" => "11223344",
        "email" => "user@emcasa.com",
        "password" => "password",
        "deviceToken" => "asdasdasd"
      }

      mutation = """
        mutation Register($name: String!, $phone: String, $email: String!, $password: String!, $deviceToken: String){
          register(
            name: $name,
            phone: $phone,
            email: $email,
            password: $password,
            deviceToken: $deviceToken
          ){
            jwt
            user {
              name
              email
              phone
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "name" => "name",
               "email" => "user@emcasa.com",
               "phone" => "11223344"
             } == json_response(conn, 200)["data"]["register"]["user"]

      assert json_response(conn, 200)["data"]["register"]["jwt"]
      assert user = Repo.get_by(User, email: "user@emcasa.com")
      assert "name" == user.name
      assert "11223344" == user.phone
      assert "asdasdasd" == user.device_token
      assert Bcrypt.checkpw("password", user.password_hash)
      refute user.confirmed
      assert user.confirmation_token
      assert "user" == user.role
    end

    test "should not register with same email", %{unauthenticated_conn: conn} do
      insert(:user, email: "user@emcasa.com")

      variables = %{
        "name" => "name",
        "phone" => "11223344",
        "email" => "user@emcasa.com",
        "password" => "password",
        "deviceToken" => "asdasdasd"
      }

      mutation = """
        mutation Register($name: String!, $phone: String, $email: String!, $password: String!, $deviceToken: String){
          register(
            name: $name,
            phone: $phone,
            email: $email,
            password: $password,
            deviceToken: $deviceToken
          ){
            jwt
            user {
              name
              email
              phone
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "email: has already been taken", "code" => 422}] =
               json_response(conn, 200)["errors"]
    end
  end

  describe "confirm" do
    test "should confirm user registration", %{unauthenticated_conn: conn} do
      %{id: id} = insert(:user, confirmed: false, confirmation_token: "token")

      variables = %{"token" => "token"}

      mutation = """
        mutation Confirm($token: String!) {
          confirm(token: $token) {
            jwt
            user {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "id" => to_string(id)
             } == json_response(conn, 200)["data"]["confirm"]["user"]

      assert json_response(conn, 200)["data"]["confirm"]["jwt"]
      assert user = Repo.get(User, id)
      assert user.confirmed
    end

    test "should not confirm user with wrong token", %{unauthenticated_conn: conn} do
      %{id: id} = insert(:user, confirmed: false, confirmation_token: "token")

      variables = %{"token" => "wrongtoken"}

      mutation = """
        mutation Confirm($token: String!) {
          confirm(token: $token) {
            jwt
            user {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Bad request", "code" => 400}] = json_response(conn, 200)["errors"]

      assert user = Repo.get(User, id)
      refute user.confirmed
    end
  end

  describe "resetPassword" do
    test "should request password reset", %{unauthenticated_conn: conn} do
      %{id: id} = insert(:user, email: "user@emcasa.com")

      variables = %{"email" => "user@emcasa.com"}

      mutation = """
        mutation ResetPassword($email: String!) {
          resetPassword(email: $email) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "id" => to_string(id)
             } == json_response(conn, 200)["data"]["resetPassword"]

      assert user = Repo.get(User, id)
      assert user.reset_token
    end

    test "should not request password reset with wrong e-mail", %{unauthenticated_conn: conn} do
      variables = %{"email" => "inexistinguser@emcasa.com"}

      mutation = """
        mutation ResetPassword($email: String!) {
          resetPassword(email: $email) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Not found", "code" => 404}] = json_response(conn, 200)["errors"]
    end
  end

  describe "redefinePassword" do
    test "should request password reset", %{unauthenticated_conn: conn} do
      %{id: id} = insert(:user, reset_token: "token")

      variables = %{
        "resetToken" => "token",
        "newPassword" => "newpassword"
      }

      mutation = """
        mutation RedefinePassword($resetToken: String!, $newPassword: String!) {
          redefinePassword(resetToken: $resetToken, newPassword: $newPassword) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "id" => to_string(id)
             } == json_response(conn, 200)["data"]["redefinePassword"]

      assert user = Repo.get(User, id)
      assert Bcrypt.checkpw("newpassword", user.password_hash)
      refute user.reset_token
    end

    test "should not redefine password with wrong token", %{unauthenticated_conn: conn} do
      insert(:user, reset_token: "token")

      variables = %{
        "resetToken" => "wrongtoken",
        "newPassword" => "newpassword"
      }

      mutation = """
        mutation RedefinePassword($resetToken: String!, $newPassword: String!) {
          redefinePassword(resetToken: $resetToken, newPassword: $newPassword) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Not found", "code" => 404}] = json_response(conn, 200)["errors"]
    end
  end

  describe "accountKitSignIn" do
    test "should register with account kit", %{unauthenticated_conn: conn} do
      variables = %{
        "accessToken" => "valid_access_token"
      }

      mutation = """
        mutation AccountKitSignIn($accessToken: String!) {
          accountKitSignIn(accessToken: $accessToken) {
            jwt
            user {
              phone
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "phone" => "+5511999999999"
             } == json_response(conn, 200)["data"]["accountKitSignIn"]["user"]

      assert json_response(conn, 200)["data"]["accountKitSignIn"]["jwt"]
    end

    test "should sign in with account kit", %{unauthenticated_conn: conn} do
      user = insert(:user, account_kit_id: "321", phone: "+5511999999999")

      variables = %{
        "accessToken" => "valid_access_token"
      }

      mutation = """
        mutation AccountKitSignIn($accessToken: String!) {
          accountKitSignIn(accessToken: $accessToken) {
            jwt
            user {
              id
              phone
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "id" => to_string(user.id),
               "phone" => user.phone
             } == json_response(conn, 200)["data"]["accountKitSignIn"]["user"]

      assert json_response(conn, 200)["data"]["accountKitSignIn"]["jwt"]
    end
  end
end
