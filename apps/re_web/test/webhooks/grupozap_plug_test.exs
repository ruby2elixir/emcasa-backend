defmodule ReWeb.Webhooks.GrupozapPlugTest do
  use ReWeb.ConnCase

  alias Re.{
    Leads.Buyer.JobQueue,
    Leads.GrupozapBuyer,
    Repo
  }

  @payload %{
    "leadOrigin" => "VivaReal",
    "timestamp" => "2019-01-01T00:00:00.000Z",
    "originLeadId" => "59ee0fc6e4b043e1b2a6d863",
    "originListingId" => "87027856",
    "clientListingId" => "a40171",
    "name" => "mah name",
    "email" => "mah@email",
    "ddd" => "11",
    "phone" => "999999999",
    "message" => "mah msg"
  }

  @invalid_payload %{
    "leadOrigin" => "VivaReal",
    "timestamp" => "2019-01-01T00:00:00.000Z",
    "originLeadId" => "59ee0fc6e4b043e1b2a6d863",
    "originListingId" => "87027856",
    "clientListingId" => nil,
    "name" => "mah name",
    "email" => "mah@email",
    "ddd" => "11",
    "phone" => "999999999",
    "message" => "mah msg"
  }

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")

    encoded_secret = Base.encode64("vivareal:testsecret")
    wrong_secret = Base.encode64("vivareal:wrongsecret")

    {:ok,
     unauthenticated_conn: conn,
     authenticated_conn: put_req_header(conn, "authorization", "Basic #{encoded_secret}"),
     invalid_conn: put_req_header(conn, "authorization", "Basic #{wrong_secret}")}
  end

  describe "POST" do
    test "authenticated request", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/grupozap", @payload)

      assert text_response(conn, 200) == "ok"

      assert gb = Repo.one(GrupozapBuyer)
      assert gb.origin_lead_id
      assert gb.origin_listing_id
      assert gb.client_listing_id
      assert Repo.one(JobQueue)
    end

    @long_message_payload %{
      "leadOrigin" => "VivaReal",
      "timestamp" => "2019-01-01T00:00:00.000Z",
      "originLeadId" => "59ee0fc6e4b043e1b2a6d863",
      "originListingId" => "87027856",
      "clientListingId" => "a40171",
      "name" => "mah name",
      "email" => "mah@email",
      "ddd" => "11",
      "phone" => "999999999",
      "message" => String.duplicate("a", 256)
    }

    test "should save long message", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/grupozap", @long_message_payload)

      assert text_response(conn, 200) == "ok"

      assert gb = Repo.one(GrupozapBuyer)
      assert gb.message
      assert Repo.one(JobQueue)
    end

    @tag capture_log: true
    test "invalid payload", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/grupozap", %{"wat" => "ok"})

      assert text_response(conn, 422) == "Unprocessable Entity"

      refute Repo.one(GrupozapBuyer)
      refute Repo.one(JobQueue)
    end

    test "unauthenticated request", %{unauthenticated_conn: conn} do
      conn = post(conn, "/webhooks/grupozap", @payload)

      assert text_response(conn, 401) == "Unauthorized"

      refute Repo.one(GrupozapBuyer)
      refute Repo.one(JobQueue)
    end

    test "invalid auth request", %{invalid_conn: conn} do
      conn = post(conn, "/webhooks/grupozap", @payload)

      assert text_response(conn, 401) == "Unauthorized"

      refute Repo.one(GrupozapBuyer)
      refute Repo.one(JobQueue)
    end

    @tag capture_log: true
    test "invalid clientListingId request", %{authenticated_conn: conn} do
      conn = post(conn, "/webhooks/grupozap", @invalid_payload)

      assert text_response(conn, 422) == "Unprocessable Entity"

      refute Repo.one(GrupozapBuyer)
      refute Repo.one(JobQueue)
    end
  end

  describe "GET" do
    test "authenticated request", %{authenticated_conn: conn} do
      conn = get(conn, "/webhooks/grupozap", @payload)

      assert text_response(conn, 405) == "GET not allowed"

      refute Repo.one(GrupozapBuyer)
      refute Repo.one(JobQueue)
    end
  end
end
