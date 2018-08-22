defmodule ReWeb.GraphQL.Blacklists.QueryTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok, user_user: user_user, user_conn: login_as(conn, user_user)}
  end

  describe "userProfile" do
    test "user should get his blacklisted listings", %{user_conn: conn, user_user: user} do
      blacklisted_listing1 = insert(:listing, type: "Casa", score: 4)
      blacklisted_listing2 = insert(:listing, type: "Casa", score: 3)
      blacklisted_listing3 = insert(:listing, type: "Apartamento")

      insert(:listing_blacklist, listing: blacklisted_listing1, user: user)
      insert(:listing_blacklist, listing: blacklisted_listing2, user: user)
      insert(:listing_blacklist, listing: blacklisted_listing3, user: user)

      variables = %{
        "id" => user.id,
        "pagination" => %{
          "pageSize" => 1
        },
        "filters" => %{
          "types" => ["Casa"]
        }
      }

      query = """
        query UserProfile($id: ID, $pagination: ListingPagination, $filters: ListingFilterInput) {
          userProfile(ID: $id) {
            id
            blacklists (
              pagination: $pagination
              filters: $filters
            ) {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
                 "id" => to_string(user.id),
                 "blacklists" => [
                   %{"id" => to_string(blacklisted_listing1.id)}
                 ]
             } == json_response(conn, 200)["data"]["userProfile"]
    end
  end
end
