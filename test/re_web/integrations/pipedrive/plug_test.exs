defmodule ReWeb.Integrations.Pipedrive.PlugTest do
  use ReWeb.ConnCase

  import Re.Factory

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")

    authenticated_conn =
      conn
      |> put_req_header("php-auth-user", "testuser")
      |> put_req_header("php-auth-pw", "testpass")

    {:ok, unauthenticated_conn: conn, authenticated_conn: authenticated_conn}
  end

  describe "updated.activity" do
    test "authenticated request", %{authenticated_conn: conn} do
      conn =
        post(conn, "/webhooks/pipedrive", %{
          event: "updated.activity",
          current: %{type: "visita_ao_imvel", done: true},
          previous: %{done: false}
        })

      assert text_response(conn, 200) == "ok"
    end

    test "unhandled webhook", %{authenticated_conn: conn} do
      conn =
        post(conn, "/webhooks/pipedrive", %{
          event: "updated.activity",
          current: %{type: "visita_ao_imvel", done: true},
          previous: %{done: true}
        })

      assert text_response(conn, 422) == "Webhook not handled"
    end

    test "unauthenticated request", %{unauthenticated_conn: conn} do
      conn = post(conn, "/webhooks/pipedrive", %{event: "update.activity"})

      assert text_response(conn, 403) == "Unauthorized"
    end
  end
end
