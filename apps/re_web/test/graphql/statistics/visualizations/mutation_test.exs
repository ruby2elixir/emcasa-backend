defmodule ReWeb.GraphQL.Statistics.Visualizations.MutationTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_user: admin_user,
     user_user: user_user,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  describe "tourVisualized" do
    test "should register visualization for admin", %{admin_conn: conn} do
      %{id: listing_id} = insert(:listing)

      variables = %{
        "id" => listing_id
      }

      mutation = """
        mutation TourVisualized($id: ID!) {
          tourVisualized(id: $id) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      listing_id_str = to_string(listing_id)
      assert %{"tourVisualized" => %{"id" => ^listing_id_str}} = json_response(conn, 200)["data"]
    end

    test "should register visualization for user", %{user_conn: conn} do
      %{id: listing_id} = insert(:listing)

      variables = %{
        "id" => listing_id
      }

      mutation = """
        mutation TourVisualized($id: ID!) {
          tourVisualized(id: $id) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      listing_id_str = to_string(listing_id)
      assert %{"tourVisualized" => %{"id" => ^listing_id_str}} = json_response(conn, 200)["data"]
    end

    test "should register visualization for anonymous", %{unauthenticated_conn: conn} do
      %{id: listing_id} = insert(:listing)

      variables = %{
        "id" => listing_id
      }

      mutation = """
        mutation TourVisualized($id: ID!) {
          tourVisualized(id: $id) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      listing_id_str = to_string(listing_id)
      assert %{"tourVisualized" => %{"id" => ^listing_id_str}} = json_response(conn, 200)["data"]
    end
  end
end
