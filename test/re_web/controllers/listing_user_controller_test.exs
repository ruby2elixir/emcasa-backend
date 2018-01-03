defmodule ReWeb.ListingUserControllerTest do
  use ReWeb.ConnCase

  import Re.Factory
  import Swoosh.TestAssertions

  alias Re.User

  @user_params %{name: "Test Name", email: "test@email.com", password: "somepass"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create" do
    test "show interest in listing", %{conn: conn} do
      listing = insert(:listing)
      conn = dispatch(conn, @endpoint, "post", "/listings_users", %{user: @user_params, listing: %{id: listing.id}})
      response = json_response(conn, 201)

      user_id = response["data"]["id"]
      user = Repo.get(User, user_id)
      assert_email_sent Re.UserEmail.notify_interest(user, listing.id)
    end
  end
end
