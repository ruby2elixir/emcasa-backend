defmodule ReWeb.GraphQL.BlacklistsTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias Re.Blacklist

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

  describe "listingBlacklist" do
    test "admin should blacklist listing", %{admin_conn: conn, admin_user: user} do
      listing = insert(:listing)

      mutation = """
        mutation {
          listingBlacklist(id: #{listing.id}) {
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
      assert Repo.get_by(Blacklist, listing_id: listing.id, user_id: user.id)

      assert %{
               "listingBlacklist" => %{
                 "listing" => %{"id" => ^listing_id},
                 "user" => %{"id" => ^user_id}
               }
             } = json_response(conn, 200)["data"]
    end

    test "user should blacklist listing", %{user_conn: conn, user_user: user} do
      listing = insert(:listing)

      mutation = """
        mutation {
          listingBlacklist(id: #{listing.id}) {
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
      assert Repo.get_by(Blacklist, listing_id: listing.id, user_id: user.id)

      assert %{
               "listingBlacklist" => %{
                 "listing" => %{"id" => ^listing_id},
                 "user" => %{"id" => ^user_id}
               }
             } = json_response(conn, 200)["data"]
    end

    test "anonymous should not blacklist listing", %{unauthenticated_conn: conn} do
      listing = insert(:listing)

      mutation = """
        mutation {
          listingBlacklist(id: #{listing.id}) {
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

      assert [] == Repo.all(Blacklist)
      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end
  end

  describe "listingUnblacklist" do
    test "admin should unblacklist listing", %{admin_conn: conn, admin_user: %{id: user_id}} do
      %{id: listing_id} = insert(:listing)
      insert(:listing_blacklist, listing_id: listing_id, user_id: user_id)

      mutation = """
        mutation {
          listingUnblacklist(id: #{listing_id}) {
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

      assert %{
               "listingUnblacklist" => %{
                 "listing" => %{"id" => ^listing_id_str},
                 "user" => %{"id" => ^user_id_str}
               }
             } = json_response(conn, 200)["data"]

      refute Repo.get_by(Blacklist, listing_id: listing_id, user_id: user_id)
    end

    test "user should unblacklist listing", %{user_conn: conn, user_user: %{id: user_id}} do
      %{id: listing_id} = insert(:listing)
      insert(:listing_blacklist, listing_id: listing_id, user_id: user_id)

      mutation = """
        mutation {
          listingUnblacklist(id: #{listing_id}) {
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

      assert %{
               "listingUnblacklist" => %{
                 "listing" => %{"id" => ^listing_id_str},
                 "user" => %{"id" => ^user_id_str}
               }
             } = json_response(conn, 200)["data"]

      refute Repo.get_by(Blacklist, listing_id: listing_id, user_id: user_id)
    end

    test "anonymous should not unblacklist listing", %{unauthenticated_conn: conn} do
      listing = insert(:listing)

      mutation = """
        mutation {
          listingUnblacklist(id: #{listing.id}) {
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
      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end
  end
end
