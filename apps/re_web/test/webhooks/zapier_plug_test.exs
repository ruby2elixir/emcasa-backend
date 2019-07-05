defmodule ReWeb.Webhooks.ZapierPlugTest do
  use ReWeb.ConnCase

  alias Re.{
    BuyerLeads,
    BuyerLeads.ImovelWeb,
    SellerLeads,
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
    "source" => "facebook_buyer",
    "budget" => "$1000 to $10000"
  }

  @facebook_buyer_invalid_payload %{
    "full_name" => "mah full naem",
    "timestamp" => "2019-01-01T00:00:00.000Z",
    "lead_id" => "193846287346183764187",
    "email" => "mah@email",
    "phone_number" => "11999999999",
    "neighborhoods" => "manhattan brooklyn harlem",
    "location" => "asdasda",
    "source" => "facebook_buyer",
    "budget" => "$1000 to $10000"
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

      assert fb = Repo.one(BuyerLeads.Facebook)
      assert fb.uuid
    end

    @tag capture_log: true
    test "invalid payload", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", %{"wat" => "ok"})

      assert text_response(conn, 422) == "Unprocessable Entity"

      refute Repo.one(BuyerLeads.Facebook)
    end

    test "unauthenticated request", %{unauthenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @facebook_buyer_payload)

      assert text_response(conn, 401) == "Unauthorized"

      refute Repo.one(BuyerLeads.Facebook)
    end

    test "invalid auth request", %{invalid_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @facebook_buyer_payload)

      assert text_response(conn, 401) == "Unauthorized"

      refute Repo.one(BuyerLeads.Facebook)
    end

    @tag capture_log: true
    test "invalid location request", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @facebook_buyer_invalid_payload)

      assert text_response(conn, 422) == "Unprocessable Entity"

      refute Repo.one(BuyerLeads.Facebook)
    end

    test "get should not be allowed", %{authenticated_conn: conn} do
      conn = get(conn, "/webhooks/zapier", @facebook_buyer_payload)

      assert text_response(conn, 405) == "GET not allowed"

      refute Repo.one(BuyerLeads.Facebook)
    end
  end

  @imovelweb_buyer_payload %{
    "name" => "mah full naem",
    "email" => "mah@emcasa.com",
    "phone" => "11999999999",
    "listingId" => "2000",
    "source" => "imovelweb_buyer"
  }

  @imovelweb_buyer_no_listing_payload %{
    "source" => "imovelweb_buyer"
  }

  @imovelweb_buyer_no_contact_payload %{
    "listingId" => "2000",
    "source" => "imovelweb_buyer"
  }

  describe "imovelweb buyer leads" do
    test "authenticated request", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @imovelweb_buyer_payload)

      assert text_response(conn, 200) == "ok"

      assert fb = Repo.one(ImovelWeb)
      assert fb.uuid
    end

    @tag capture_log: true
    test "invalid payload", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", %{"wat" => "ok"})

      assert text_response(conn, 422) == "Unprocessable Entity"

      refute Repo.one(ImovelWeb)
    end

    test "unauthenticated request", %{unauthenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @imovelweb_buyer_payload)

      assert text_response(conn, 401) == "Unauthorized"

      refute Repo.one(ImovelWeb)
    end

    test "invalid auth request", %{invalid_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @imovelweb_buyer_payload)

      assert text_response(conn, 401) == "Unauthorized"

      refute Repo.one(ImovelWeb)
    end

    @tag capture_log: true
    test "missing attributes request", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @imovelweb_buyer_no_listing_payload)

      assert text_response(conn, 422) == "Unprocessable Entity"

      refute Repo.one(ImovelWeb)
    end

    test "get should now be allowed", %{authenticated_conn: conn} do
      conn = get(conn, "/webhooks/zapier", @imovelweb_buyer_payload)

      assert text_response(conn, 405) == "GET not allowed"

      refute Repo.one(ImovelWeb)
    end
  end

  @tag capture_log: true
  test "invalid source", %{authenticated_conn: conn} do
    conn = post(conn, "/webhooks/zapier", %{"source" => "whatever"})

    assert text_response(conn, 422) == "Unprocessable Entity"

    refute Repo.one(BuyerLeads.Facebook)
    refute Repo.one(ImovelWeb)
  end

  @tag capture_log: true
  test "inexisting source", %{authenticated_conn: conn} do
    conn = post(conn, "/webhooks/zapier", %{})

    assert text_response(conn, 422) == "Unprocessable Entity"

    refute Repo.one(BuyerLeads.Facebook)
    refute Repo.one(ImovelWeb)
  end

  test "authenticated request", %{authenticated_conn: conn} do
    conn = post(conn, "/webhooks/zapier", @imovelweb_buyer_no_contact_payload)

    assert text_response(conn, 200) == "ok"

    assert fb = Repo.one(ImovelWeb)
    assert fb.uuid
  end

  @facebook_seller_payload %{
    "full_name" => "mah full naem",
    "timestamp" => "2019-01-01T00:00:00.000Z",
    "lead_id" => "193846287346183764187",
    "email" => "mah@email",
    "phone_number" => "11999999999",
    "neighborhoods" => "manhattan brooklyn harlem",
    "objective" => "just chillin",
    "location" => "RJ",
    "source" => "facebook_seller"
  }

  @facebook_seller_invalid_payload %{
    "full_name" => "mah full naem",
    "timestamp" => "2019-01-01T00:00:00.000Z",
    "lead_id" => "193846287346183764187",
    "email" => "mah@email",
    "phone_number" => "11999999999",
    "neighborhoods" => "manhattan brooklyn harlem",
    "objective" => "just chillin",
    "location" => "asdasda",
    "source" => "facebook_buyer"
  }

  describe "facebook seller leads" do
    test "authenticated request", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @facebook_seller_payload)

      assert text_response(conn, 200) == "ok"

      assert fb = Repo.one(SellerLeads.Facebook)
      assert fb.uuid
    end

    @tag capture_log: true
    test "invalid payload", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", %{"wat" => "ok"})

      assert text_response(conn, 422) == "Unprocessable Entity"

      refute Repo.one(SellerLeads.Facebook)
    end

    test "unauthenticated request", %{unauthenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @facebook_seller_payload)

      assert text_response(conn, 401) == "Unauthorized"

      refute Repo.one(SellerLeads.Facebook)
    end

    test "invalid auth request", %{invalid_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @facebook_seller_payload)

      assert text_response(conn, 401) == "Unauthorized"

      refute Repo.one(SellerLeads.Facebook)
    end

    @tag capture_log: true
    test "invalid location request", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/zapier", @facebook_seller_invalid_payload)

      assert text_response(conn, 422) == "Unprocessable Entity"

      refute Repo.one(SellerLeads.Facebook)
    end

    test "get should not be allowed", %{authenticated_conn: conn} do
      conn = get(conn, "/webhooks/zapier", @facebook_seller_payload)

      assert text_response(conn, 405) == "GET not allowed"

      refute Repo.one(SellerLeads.Facebook)
    end
  end
end
