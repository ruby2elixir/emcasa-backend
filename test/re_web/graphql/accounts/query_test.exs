defmodule ReWeb.GraphQL.Accounts.QueryTest do
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

  describe "userProfile" do
    test "admin should get any user profile", %{admin_conn: conn} do
      inserted_user =
        insert(:user, name: "Tester John", email: "tester.john@emcasa.com", phone: "123456789")

      listing1 = insert(:listing, user: inserted_user, type: "Casa", score: 4)
      insert(:listing, user: inserted_user, type: "Casa", score: 3)
      insert(:listing, user: inserted_user, type: "Apartamento")

      favorited_listing1 = insert(:listing, type: "Casa", score: 4)
      favorited_listing2 = insert(:listing, type: "Casa", score: 3)
      favorited_listing3 = insert(:listing, type: "Apartamento")

      insert(:listings_favorites, listing: favorited_listing1, user: inserted_user)
      insert(:listings_favorites, listing: favorited_listing2, user: inserted_user)
      insert(:listings_favorites, listing: favorited_listing3, user: inserted_user)

      query = """
        {
          userProfile(ID: #{inserted_user.id}) {
            id
            name
            email
            phone
            listings (
              pagination: {pageSize: 1}
              filters: {types: ["Casa"]}
            ) {
              id
            }
            favorites (
              pagination: {pageSize: 1}
              filters: {types: ["Casa"]}
            ) {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "userProfile"))

      user_id = to_string(inserted_user.id)
      user_name = to_string(inserted_user.name)
      user_email = to_string(inserted_user.email)
      user_phone = to_string(inserted_user.phone)
      listing1_id = to_string(listing1.id)
      favorited_listing1_id = to_string(favorited_listing1.id)

      assert %{
               "userProfile" => %{
                 "id" => ^user_id,
                 "name" => ^user_name,
                 "email" => ^user_email,
                 "phone" => ^user_phone,
                 "listings" => [
                   %{"id" => ^listing1_id}
                 ],
                 "favorites" => [
                   %{"id" => ^favorited_listing1_id}
                 ]
               }
             } = json_response(conn, 200)["data"]
    end

    test "user should get his own profile", %{user_conn: conn, user_user: user} do
      listing1 = insert(:listing, user: user, type: "Casa", score: 4)
      insert(:listing, user: user, type: "Casa", score: 3)
      insert(:listing, user: user, type: "Apartamento")

      favorited_listing1 = insert(:listing, type: "Casa", score: 4)
      favorited_listing2 = insert(:listing, type: "Casa", score: 3)
      favorited_listing3 = insert(:listing, type: "Apartamento")

      insert(:listings_favorites, listing: favorited_listing1, user: user)
      insert(:listings_favorites, listing: favorited_listing2, user: user)
      insert(:listings_favorites, listing: favorited_listing3, user: user)

      query = """
        {
          userProfile(ID: #{user.id}) {
            id
            name
            email
            phone
            listings (
              pagination: {pageSize: 1}
              filters: {types: ["Casa"]}
            ) {
              id
            }
            favorites (
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
      user_name = to_string(user.name)
      user_email = to_string(user.email)
      user_phone = to_string(user.phone)
      listing1_id = to_string(listing1.id)
      favorited_listing1_id = to_string(favorited_listing1.id)

      assert %{
               "userProfile" => %{
                 "id" => ^user_id,
                 "name" => ^user_name,
                 "email" => ^user_email,
                 "phone" => ^user_phone,
                 "listings" => [
                   %{"id" => ^listing1_id}
                 ],
                 "favorites" => [
                   %{"id" => ^favorited_listing1_id}
                 ]
               }
             } = json_response(conn, 200)["data"]
    end

    test "user should get his own profile without passing id as parameter", %{
      user_conn: conn,
      user_user: user
    } do
      query = """
        {
          userProfile {
            id
            name
            email
            phone
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "userProfile"))

      user_id = to_string(user.id)
      user_name = to_string(user.name)
      user_email = to_string(user.email)
      user_phone = to_string(user.phone)

      assert %{
               "userProfile" => %{
                 "id" => ^user_id,
                 "name" => ^user_name,
                 "email" => ^user_email,
                 "phone" => ^user_phone
               }
             } = json_response(conn, 200)["data"]
    end

    test "anonymous should not get user profile", %{unauthenticated_conn: conn} do
      user =
        insert(:user, name: "Tester John", email: "tester.john@emcasa.com", phone: "123456789")

      query = """
        {
          userProfile(ID: #{user.id}) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "userProfile"))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end

    test "user should not get other user's profile", %{user_conn: conn} do
      inserted_user =
        insert(:user, name: "Tester John", email: "tester.john@emcasa.com", phone: "123456789")

      query = """
        {
          userProfile(ID: #{inserted_user.id}) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "userProfile"))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end
  end
end
