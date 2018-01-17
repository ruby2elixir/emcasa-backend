defmodule ReWeb.SessionControllerTest do
  use ReWeb.ConnCase

  import Re.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create" do
    test "successful login", %{conn: conn} do
      user = insert(:user)
      conn = post conn, session_path(conn, :create, %{"user" => %{"email" => user.email, "password" => "password"}})
      assert response = json_response(conn, 201)
      assert response["user"]["token"]
    end

    test "fails when password is incorrect", %{conn: conn} do
      user = insert(:user)
      conn = post conn, session_path(conn, :create, %{"user" => %{"email" => user.email, "password" => "wrongpass"}})
      assert response = json_response(conn, 401)
      assert response["message"] == "Could not login"
    end

    test "fails when user doesn't exist", %{conn: conn} do
      conn = post conn, session_path(conn, :create, %{"user" => %{"email" => "wrong@email.com", "password" => "password"}})
      assert response = json_response(conn, 401)
      assert response["message"] == "Could not login"
    end
  end
end
