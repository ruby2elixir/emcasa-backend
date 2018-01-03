defmodule ReWeb.ListingUserControllerTest do
  use ReWeb.ConnCase

  import Re.Factory
  import Swoosh.TestAssertions

  alias Re.User

  @user_params %{name: "Test Name", email: "test@email.com", password: "somepass"}

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn =
      conn
      |> put_req_header("accept", "application/json")

    authenticated_conn = put_req_header(conn, "authorization", "Token #{jwt}")
    {:ok, authenticated_conn: authenticated_conn, unauthenticated_conn: conn}
  end

  describe "create" do
    test "succeeds if authenticated", %{authenticated_conn: conn} do
      listing = insert(:listing)
      conn = dispatch(conn, @endpoint, "post", "/listings_users", %{user: @user_params, listing: %{id: listing.id}})
      response = json_response(conn, 201)

      user_id = response["data"]["id"]
      user = Repo.get(User, user_id)
      assert_email_sent Re.UserEmail.notify_interest(user, listing.id)
    end

    test "failes if unauthenticated", %{unauthenticated_conn: conn} do
      listing = insert(:listing)
      conn = post conn, listing_user_path(conn, :create, user: @user_params, listing: listing)
      json_response(conn, 403)
    end
  end
end
