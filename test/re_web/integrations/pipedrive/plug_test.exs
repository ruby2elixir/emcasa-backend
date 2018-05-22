defmodule ReWeb.Integrations.Pipedrive.PlugTest do
  use ReWeb.ConnCase

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")

    encoded_user_pass = Base.encode64("testuser:testpass")

    {:ok,
     unauthenticated_conn: conn,
     authenticated_conn: put_req_header(conn, "authorization", "Basic #{encoded_user_pass}")}
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
