defmodule ReWeb.Webhooks.ZapierPlugTest do
  use ReWeb.ConnCase

  alias Re.{
    Leads.FacebookBuyer,
    Repo
  }

  @payload %{
      "full_name" => "mah full naem",
      "timestamp" => "2019-01-01T00:00:00.000Z",
      "lead_id" => "193846287346183764187",
      "email" => "mah@email",
      "phone_number" => "11999999999",
      "neighborhoods" => "manhattan brooklyn harlem"
    }

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")

    encoded_secret = Base.encode64("testuser:testpass")
    wrong_credentials = Base.encode64("testuser:wrongpass")

    {:ok,
     unauthenticated_conn: conn,
     authenticated_conn: put_req_header(conn, "authorization", "Basic #{encoded_secret}"),
     invalid_conn: put_req_header(conn, "authorization", "Basic #{wrong_credentials}")}
  end

  describe "POST" do
    test "authenticated request", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @payload)

      assert text_response(conn, 200) == "ok"

      assert Repo.one(FacebookBuyer)
    end

    @tag capture_log: true
    test "invalid payload", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", %{"wat" => "ok"})

      assert text_response(conn, 422) == "Unprocessable Entity"

      refute Repo.one(FacebookBuyer)
    end

    test "unauthenticated request", %{unauthenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @payload)

      assert text_response(conn, 401) == "Unauthorized"

      refute Repo.one(FacebookBuyer)
    end

    test "invalid auth request", %{invalid_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @payload)

      assert text_response(conn, 401) == "Unauthorized"

      refute Repo.one(FacebookBuyer)
    end
  end

  describe "GET" do
    test "authenticated request", %{authenticated_conn: conn} do
      conn = get(conn, "/webhooks/zapier", @payload)

      assert text_response(conn, 405) == "GET not allowed"

      refute Repo.one(FacebookBuyer)
    end
  end
end
