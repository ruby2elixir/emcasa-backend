defmodule ReWeb.GraphQL.ListingsTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias Re.Listing
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

  describe "activateListing" do
    test "admin should activate listing", %{admin_conn: conn} do
      listing = insert(:listing, is_active: false)

      mutation = """
        mutation {
          activateListing(id: #{listing.id}) {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert listing = Repo.get(Listing, listing.id)
      assert listing.is_active
    end

    test "user should not activate listing", %{user_conn: conn} do
      listing = insert(:listing, is_active: false)

      mutation = """
        mutation {
          activateListing(id: #{listing.id}) {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert listing = Repo.get(Listing, listing.id)
      refute listing.is_active
    end

    test "anonymous should not activate listing", %{unauthenticated_conn: conn} do
      listing = insert(:listing, is_active: false)

      mutation = """
        mutation {
          activateListing(id: #{listing.id}) {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert listing = Repo.get(Listing, listing.id)
      refute listing.is_active
    end
  end

  describe "deactivateListing" do
    test "admin should deactivate listing", %{admin_conn: conn} do
      listing = insert(:listing, is_active: true)

      mutation = """
        mutation {
          deactivateListing(id: #{listing.id}) {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert listing = Repo.get(Listing, listing.id)
      refute listing.is_active
    end

    test "user should not deactivate listing", %{user_conn: conn} do
      listing = insert(:listing, is_active: true)

      mutation = """
        mutation {
          deactivateListing(id: #{listing.id}) {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert listing = Repo.get(Listing, listing.id)
      assert listing.is_active
    end

    test "anonymous should not deactivate listing", %{unauthenticated_conn: conn} do
      listing = insert(:listing, is_active: true)

      mutation = """
        mutation {
          deactivateListing(id: #{listing.id}) {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert listing = Repo.get(Listing, listing.id)
      assert listing.is_active
    end
  end
end
