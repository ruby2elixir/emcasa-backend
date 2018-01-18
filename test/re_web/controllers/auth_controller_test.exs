defmodule ReWeb.AuthControllerTest do
  use ReWeb.ConnCase

  import Re.Factory
  import Swoosh.TestAssertions

  alias Re.{
    Repo,
    User
  }

  alias Comeonin.Bcrypt
  alias ReWeb.UserEmail

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "login" do
    test "successful login", %{conn: conn} do
      user = insert(:user)

      conn =
        post(
          conn,
          auth_path(conn, :login, %{"user" => %{"email" => user.email, "password" => "password"}})
        )

      assert response = json_response(conn, 201)
      assert response["user"]["token"]
    end

    test "fails when password is incorrect", %{conn: conn} do
      user = insert(:user)

      conn =
        post(
          conn,
          auth_path(conn, :login, %{"user" => %{"email" => user.email, "password" => "wrongpass"}})
        )

      assert json_response(conn, 401)
    end

    test "fails when user doesn't exist", %{conn: conn} do
      conn =
        post(
          conn,
          auth_path(conn, :login, %{
            "user" => %{"email" => "wrong@email.com", "password" => "password"}
          })
        )

      assert json_response(conn, 401)
    end
  end

  describe "register" do
    test "successful registration", %{conn: conn} do
      user_params = %{
        "name" => "mahname",
        "email" => "validemail@emcasa.com",
        "password" => "validpassword"
      }

      conn = post(conn, auth_path(conn, :register, %{"user" => user_params}))
      assert json_response(conn, 201)
      assert user = Repo.get_by(User, email: "validemail@emcasa.com")
      assert user.confirmation_token
      refute user.confirmed
      assert_email_sent(UserEmail.confirm(user))
    end

    test "fails when password is invalid", %{conn: conn} do
      user_params = %{
        "name" => "mahname",
        "email" => "validemail@emcasa.com",
        "password" => ""
      }

      conn = post(conn, auth_path(conn, :register, %{"user" => user_params}))
      assert json_response(conn, 422)
    end

    test "fails when email is invalid", %{conn: conn} do
      user_params = %{
        "name" => "mahname",
        "email" => "invalidemail",
        "password" => "password"
      }

      conn = post(conn, auth_path(conn, :register, %{"user" => user_params}))
      assert json_response(conn, 422)
    end
  end

  describe "confirm" do
    test "successfully confirm registration", %{conn: conn} do
      user =
        insert(
          :user,
          confirmation_token: "97971cce-eb6e-418a-8529-e717ca1dcf62",
          confirmed: false
        )

      conn =
        put(
          conn,
          auth_path(conn, :confirm, %{
            "id" => user.id,
            "user" => %{"token" => "97971cce-eb6e-418a-8529-e717ca1dcf62"}
          })
        )

      assert json_response(conn, 200)
      assert user = Repo.get(User, user.id)
      assert user.confirmed
      assert_email_sent(UserEmail.welcome(user))
    end

    test "does not confirm registration with wrong token", %{conn: conn} do
      user =
        insert(
          :user,
          confirmation_token: "97971cce-eb6e-418a-8529-e717ca1dcf62",
          confirmed: false
        )

      conn =
        put(
          conn,
          auth_path(conn, :confirm, %{
            "id" => user.id,
            "user" => %{"token" => "wrontoken"}
          })
        )

      assert json_response(conn, 400)
      assert user = Repo.get(User, user.id)
      refute user.confirmed
      assert_email_not_sent(UserEmail.welcome(user))
    end
  end

  describe "reset_password" do
    test "successfully request password reset", %{conn: conn} do
      user = insert(:user)

      conn =
        post(
          conn,
          auth_path(conn, :reset_password, %{
            "user" => %{"email" => user.email}
          })
        )

      assert json_response(conn, 200)
      assert user = Repo.get(User, user.id)
      assert_email_sent(UserEmail.reset_password(user))
    end

    test "does not confirm registration with wrong email", %{conn: conn} do
      user = insert(:user)

      conn =
        post(
          conn,
          auth_path(conn, :reset_password, %{
            "user" => %{"email" => "wrongemail@emcasa.com"}
          })
        )

      assert json_response(conn, 404)
      assert user = Repo.get(User, user.id)
      refute user.reset_token
    end
  end

  describe "redefine_password" do
    test "successfully redefine password", %{conn: conn} do
      user = insert(:user, reset_token: "97971cce-eb6e-418a-8529-e717ca1dcf62")

      conn =
        post(
          conn,
          auth_path(conn, :redefine_password, %{
            "user" => %{
              "reset_token" => "97971cce-eb6e-418a-8529-e717ca1dcf62",
              "password" => "newpassword"
            }
          })
        )

      assert json_response(conn, 200)
      assert user = Repo.get(User, user.id)
      assert Bcrypt.checkpw("newpassword", user.password_hash)
    end

    test "does not redefine password with wrong token", %{conn: conn} do
      user = insert(:user)

      conn =
        post(
          conn,
          auth_path(conn, :reset_password, %{
            "user" => %{"email" => "wrongtoken", "password" => "newpassword"}
          })
        )

      assert json_response(conn, 404)
      assert user = Repo.get(User, user.id)
      assert Bcrypt.checkpw("password", user.password_hash)
      refute Bcrypt.checkpw("newpassword", user.password_hash)
    end
  end
end
