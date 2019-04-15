defmodule ReWeb.Webhooks.ZapierPlugTest do
  use ReWeb.ConnCase

  alias Re.{
    Leads.FacebookBuyer,
    Leads.ImovelWebBuyer,
    Repo
  }

  @facebook_buyer_payload %{
    "full_name" => "mah full naem",
    "timestamp" => "2019-01-01T00:00:00.000Z",
    "lead_id" => "193846287346183764187",
    "email" => "mah@email",
    "phone_number" => "11999999999",
    "neighborhoods" => "manhattan brooklyn harlem",
    "location" => "RJ",
    "source" => "facebook_buyer"
  }

  @facebook_buyer_invalid_payload %{
    "full_name" => "mah full naem",
    "timestamp" => "2019-01-01T00:00:00.000Z",
    "lead_id" => "193846287346183764187",
    "email" => "mah@email",
    "phone_number" => "11999999999",
    "neighborhoods" => "manhattan brooklyn harlem",
    "location" => "asdasda",
    "source" => "facebook_buyer"
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

  describe "facebook buyer leads" do
    test "authenticated request", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @facebook_buyer_payload)

      assert text_response(conn, 200) == "ok"

      assert fb = Repo.one(FacebookBuyer)
      assert fb.uuid
    end

    @tag capture_log: true
    test "invalid payload", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", %{"wat" => "ok"})

      assert text_response(conn, 422) == "Unprocessable Entity"

      refute Repo.one(FacebookBuyer)
    end

    test "unauthenticated request", %{unauthenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @facebook_buyer_payload)

      assert text_response(conn, 401) == "Unauthorized"

      refute Repo.one(FacebookBuyer)
    end

    test "invalid auth request", %{invalid_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @facebook_buyer_payload)

      assert text_response(conn, 401) == "Unauthorized"

      refute Repo.one(FacebookBuyer)
    end

    @tag capture_log: true
    test "invalid location request", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @facebook_buyer_invalid_payload)

      assert text_response(conn, 422) == "Unprocessable Entity"

      refute Repo.one(FacebookBuyer)
    end

    test "get should not be allowed", %{authenticated_conn: conn} do
      conn = get(conn, "/webhooks/zapier", @facebook_buyer_payload)

      assert text_response(conn, 405) == "GET not allowed"

      refute Repo.one(FacebookBuyer)
    end
  end

  @imovelweb_buyer_payload %{
    "name" => "mah full naem",
    "email" => "mah@email",
    "phone" => "11999999999",
    "listingId" => "2000",
    "source" => "imovelweb_buyer"
  }

  @imovelweb_buyer_invalid_payload %{
    "name" => "mah full naem",
    "source" => "imovelweb_buyer"
  }

  describe "imovelweb buyer leads" do
    test "authenticated request", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @imovelweb_buyer_payload)

      assert text_response(conn, 200) == "ok"

      assert fb = Repo.one(ImovelWebBuyer)
      assert fb.uuid
    end

    @tag capture_log: true
    test "invalid payload", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", %{"wat" => "ok"})

      assert text_response(conn, 422) == "Unprocessable Entity"

      refute Repo.one(ImovelWebBuyer)
    end

    test "unauthenticated request", %{unauthenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @imovelweb_buyer_payload)

      assert text_response(conn, 401) == "Unauthorized"

      refute Repo.one(ImovelWebBuyer)
    end

    test "invalid auth request", %{invalid_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @imovelweb_buyer_payload)

      assert text_response(conn, 401) == "Unauthorized"

      refute Repo.one(ImovelWebBuyer)
    end

    @tag capture_log: true
    test "invalid location request", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @imovelweb_buyer_invalid_payload)

      assert text_response(conn, 422) == "Unprocessable Entity"

      refute Repo.one(ImovelWebBuyer)
    end

    test "get should now be allowed", %{authenticated_conn: conn} do
      conn = get(conn, "/webhooks/zapier", @imovelweb_buyer_payload)

      assert text_response(conn, 405) == "GET not allowed"

      refute Repo.one(ImovelWebBuyer)
    end
  end

  @tag capture_log: true
  test "invalid source", %{authenticated_conn: conn} do
    conn = post(conn, "/webhooks/zapier", %{"source" => "whatever"})

    assert text_response(conn, 422) == "Unprocessable Entity"

    refute Repo.one(FacebookBuyer)
    refute Repo.one(ImovelWebBuyer)
  end

  @tag capture_log: true
  test "inexisting source", %{authenticated_conn: conn} do
    conn = post(conn, "/webhooks/zapier", %{})

    assert text_response(conn, 422) == "Unprocessable Entity"

    refute Repo.one(FacebookBuyer)
    refute Repo.one(ImovelWebBuyer)
  end
end
