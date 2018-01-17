defmodule ReWeb.AuthControllerTest do
  use ReWeb.ConnCase

  import Re.Factory

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
end
