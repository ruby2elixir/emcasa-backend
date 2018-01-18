defmodule ReWeb.AuthControllerTest do
  use ReWeb.ConnCase

  import Re.Factory
  import Swoosh.TestAssertions

  alias Re.{
    Repo,
    User
  }
  alias ReWeb.UserEmail

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "login" do
    test "successful login", %{conn: conn} do
      user = insert(:user)
      conn = post conn, auth_path(conn, :login, %{"user" => %{"email" => user.email, "password" => "password"}})
      assert response = json_response(conn, 201)
      assert response["user"]["token"]
    end

    test "fails when password is incorrect", %{conn: conn} do
      user = insert(:user)
      conn = post conn, auth_path(conn, :login, %{"user" => %{"email" => user.email, "password" => "wrongpass"}})
      assert json_response(conn, 401)
    end

    test "fails when user doesn't exist", %{conn: conn} do
      conn = post conn, auth_path(conn, :login, %{"user" => %{"email" => "wrong@email.com", "password" => "password"}})
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

      conn = post conn, auth_path(conn, :register, %{"user" => user_params})
      assert json_response(conn, 201)
      assert user = Repo.get_by(User, email: "validemail@emcasa.com")
      assert user.confirmation_token
      refute user.confirmed
      assert_email_sent UserEmail.welcome(user)
    end

    test "fails when password is invalid", %{conn: conn} do
      user_params = %{
        "name" => "mahname",
        "email" => "validemail@emcasa.com",
        "password" => ""
      }

      conn = post conn, auth_path(conn, :register, %{"user" => user_params})
      assert json_response(conn, 422)
    end

    test "fails when email is invalid", %{conn: conn} do
      user_params = %{
        "name" => "mahname",
        "email" => "invalidemail",
        "password" => "password"
      }

      conn = post conn, auth_path(conn, :register, %{"user" => user_params})
      assert json_response(conn, 422)
    end
  end
end
