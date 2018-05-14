defmodule ReWeb.Integrations.Pipedrive.PlugTest do
  use ReWeb.ConnCase

  import Re.Factory

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    authenticated_conn =
      conn
      |> put_req_header("php-auth-user", "testuser")
      |> put_req_header("php-auth-pw", "testpass")

    {:ok,
     unauthenticated_conn: conn,
     authenticated_conn: authenticated_conn
    }
  end

  describe "updated.activity" do
    test "authenticated request", %{authenticated_conn: conn} do

      conn = post(conn, "/webhooks/pipedrive", %{event: "update.activity"})

      text_response(conn, 200)
    end

    test "unauthenticated request", %{unauthenticated_conn: conn} do

      conn = post(conn, "/webhooks/pipedrive", %{event: "update.activity"})

      text_response(conn, 403)
    end
  end

end
