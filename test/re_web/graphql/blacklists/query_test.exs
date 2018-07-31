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

      query = """
        {
          userProfile(ID: #{user.id}) {
            id
            blacklists (
              pagination: {pageSize: 1}
              filters: {types: ["Casa"]}
            ) {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "userProfile"))

      user_id = to_string(user.id)
      blacklisted_listing1_id = to_string(blacklisted_listing1.id)

      assert %{
               "userProfile" => %{
                 "id" => ^user_id,
                 "blacklists" => [
                   %{"id" => ^blacklisted_listing1_id}
                 ]
               }
             } = json_response(conn, 200)["data"]
    end
  end
end
