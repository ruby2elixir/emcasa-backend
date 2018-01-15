defmodule ReWeb.InterestControllerTest do
  use ReWeb.ConnCase

  import Re.Factory
  import Swoosh.TestAssertions

  alias Re.Listings.Interest

  @params %{name: "Test Name", email: "test@email.com"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create" do
    test "show interest in listing", %{conn: conn} do
      listing = insert(:listing)
      conn = dispatch(conn, @endpoint, "post", "/listings_users", %{user: @params, listing: %{id: listing.id}})
      response = json_response(conn, 201)

      interest_id = response["data"]["id"]
      interest = Repo.get(Interest, interest_id)
      assert_email_sent Re.UserEmail.notify_interest(interest)
    end
  end
end
