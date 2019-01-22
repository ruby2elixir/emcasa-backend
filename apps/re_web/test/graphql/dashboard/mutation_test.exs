defmodule ReWeb.GraphQL.Dashboard.MutationTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  alias Re.Listing

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")
    listing = insert(:listing)

    {:ok,
     unauthenticated_conn: conn,
     admin_user: admin_user,
     user_user: user_user,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user),
     listing: listing}
  end

  Enum.map(
    [
      {"listingHighlightVivareal", :vivareal_highlight}
    ],
    fn {mutation, attribute} ->
      @mutation mutation
      @attribute attribute

      test "admin should run #{@mutation}", %{admin_conn: conn, listing: %{id: listing_id}} do
        variables = %{
          "listingId" => listing_id
        }

        mutation = """
          mutation {
            #{@mutation}(listingId: #{listing_id}) {
              id
            }
          }
        """

        conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

        assert %{"id" => to_string(listing_id)} == json_response(conn, 200)["data"][@mutation]
        assert Listing |> Repo.get(listing_id) |> Map.get(@attribute)
      end

      test "user should not run #{@mutation}", %{user_conn: conn, listing: %{id: listing_id}} do
        variables = %{
          "listingId" => listing_id
        }

        mutation = """
          mutation {
            #{@mutation}(listingId: #{listing_id}) {
              id
            }
          }
        """

        conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

        assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
      end

      test "anonymous should not run #{@mutation}", %{
        unauthenticated_conn: conn,
        listing: %{id: listing_id}
      } do
        variables = %{
          "listingId" => listing_id
        }

        mutation = """
          mutation {
            #{@mutation}(listingId: #{listing_id}) {
              id
            }
          }
        """

        conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

        assert [%{"message" => "Unauthorized", "code" => 401}] =
                 json_response(conn, 200)["errors"]
      end
    end
  )
end
