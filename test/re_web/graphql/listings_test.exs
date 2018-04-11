defmodule ReWeb.GraphQL.ListingsTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias Re.{
    Listing,
    Listings.Favorite
  }

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

  describe "favoriteListing" do
    test "admin should favorite listing", %{admin_conn: conn, admin_user: user} do
      listing = insert(:listing)

      mutation = """
        mutation {
          favoriteListing(id: #{listing.id}) {
            listing {
              id
            }
            user {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      listing_id = to_string(listing.id)
      user_id = to_string(user.id)
      assert Repo.get_by(Favorite, listing_id: listing.id, user_id: user.id)
      assert %{"favoriteListing" => %{"listing" => %{"id" => ^listing_id}, "user" => %{"id" => ^user_id}}} = json_response(conn, 200)["data"]
    end

    test "user should favorite listing", %{user_conn: conn, user_user: user} do
      listing = insert(:listing)

      mutation = """
        mutation {
          favoriteListing(id: #{listing.id}) {
            listing {
              id
            }
            user {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      listing_id = to_string(listing.id)
      user_id = to_string(user.id)
      assert Repo.get_by(Favorite, listing_id: listing.id, user_id: user.id)
      assert %{"favoriteListing" => %{"listing" => %{"id" => ^listing_id}, "user" => %{"id" => ^user_id}}} = json_response(conn, 200)["data"]
    end

    test "anonymous should not favorite listing", %{unauthenticated_conn: conn} do
      listing = insert(:listing)

      mutation = """
        mutation {
          favoriteListing(id: #{listing.id}) {
            listing {
              id
            }
            user {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert [] == Repo.all(Favorite)
      assert [%{"message" => "unauthorized"}] = json_response(conn, 200)["errors"]
    end
  end

  describe "unfavoriteListing" do
    test "admin should unfavorite listing", %{admin_conn: conn, admin_user: %{id: user_id}} do
      %{id: listing_id} = insert(:listing)
      insert(:listing_favorite, listing_id: listing_id, user_id: user_id)

      mutation = """
        mutation {
          unfavoriteListing(id: #{listing_id}) {
            listing {
              id
            }
            user {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      listing_id_str = to_string(listing_id)
      user_id_str = to_string(user_id)
      assert %{"unfavoriteListing" => %{"listing" => %{"id" => ^listing_id_str}, "user" => %{"id" => ^user_id_str}}} = json_response(conn, 200)["data"]
      refute Repo.get_by(Favorite, listing_id: listing_id, user_id: user_id)
    end

    test "user should unfavorite listing", %{user_conn: conn, user_user: %{id: user_id}} do
      %{id: listing_id} = insert(:listing)
      insert(:listing_favorite, listing_id: listing_id, user_id: user_id)

      mutation = """
        mutation {
          unfavoriteListing(id: #{listing_id}) {
            listing {
              id
            }
            user {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      listing_id_str = to_string(listing_id)
      user_id_str = to_string(user_id)
      assert %{"unfavoriteListing" => %{"listing" => %{"id" => ^listing_id_str}, "user" => %{"id" => ^user_id_str}}} = json_response(conn, 200)["data"]
      refute Repo.get_by(Favorite, listing_id: listing_id, user_id: user_id)
    end

    test "anonymous should not unfavorite listing", %{unauthenticated_conn: conn} do
      listing = insert(:listing)

      mutation = """
        mutation {
          unfavoriteListing(id: #{listing.id}) {
            listing {
              id
            }
            user {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))
      assert [%{"message" => "unauthorized"}] = json_response(conn, 200)["errors"]
    end
  end

  describe "showFavoritedUsers" do
    test "admin should see favorited users", %{admin_conn: conn, admin_user: user} do
      listing = insert(:listing)
      insert(:listing_favorite, listing_id: listing.id, user_id: user.id)

      query = """
        {
          showFavoritedUsers(id: #{listing.id}) {
            id
          }
        }
      """

      user_id = to_string(user.id)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "showFavoritedUsers"))

      assert %{"showFavoritedUsers" => [%{"id" => ^user_id}]} = json_response(conn, 200)["data"]
    end

    test "admin should not see favorited users", %{user_conn: conn, user_user: user} do
      listing = insert(:listing)
      insert(:listing_favorite, listing_id: listing.id, user_id: user.id)

      query = """
        {
          showFavoritedUsers(id: #{listing.id}) {
            id
          }
        }
      """

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "showFavoritedUsers"))

      assert [%{"message" => "forbidden"}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not see favorited users", %{unauthenticated_conn: conn} do
      listing = insert(:listing)
      user = insert(:user)
      insert(:listing_favorite, listing_id: listing.id, user_id: user.id)

      query = """
        {
          showFavoritedUsers(id: #{listing.id}) {
            id
          }
        }
      """

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "showFavoritedUsers"))

      assert [%{"message" => "unauthorized"}] = json_response(conn, 200)["errors"]
    end
  end
end
