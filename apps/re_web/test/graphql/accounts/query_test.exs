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
      user =
        insert(:user, name: "Tester John", email: "tester.john@emcasa.com", phone: "123456789")

      listing1 = insert(:listing, user: user, type: "Casa", score: 4)
      insert(:listing, user: user, type: "Casa", score: 3)
      insert(:listing, user: user, type: "Apartamento")

      favorited_listing1 = insert(:listing, type: "Casa", score: 4)
      favorited_listing2 = insert(:listing, type: "Casa", score: 3)
      favorited_listing3 = insert(:listing, type: "Apartamento")

      insert(:listings_favorites, listing: favorited_listing1, user: user)
      insert(:listings_favorites, listing: favorited_listing2, user: user)
      insert(:listings_favorites, listing: favorited_listing3, user: user)

      variables = %{
        "id" => user.id,
        "listingPagination" => %{
          "pageSize" => 1
        },
        "listingFilters" => %{
          "types" => ["Casa"]
        },
        "favoritesPagination" => %{
          "pageSize" => 1
        },
        "favoritesFilters" => %{
          "types" => ["Casa"]
        }
      }

      query = """
        query UserProfile(
          $id: ID,
          $listingPagination: ListingPagination,
          $listingFilters: ListingFilterInput,
          $favoritesPagination: ListingPagination,
          $favoritesFilters: ListingFilterInput
          ) {
          userProfile(id: $id) {
            id
            name
            email
            phone
            listings (
              pagination: $listingPagination
              filters: $listingFilters
            ) {
              id
            }
            favorites (
              pagination: $favoritesPagination
              filters: $favoritesFilters
            ) {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "id" => to_string(user.id),
               "name" => user.name,
               "email" => user.email,
               "phone" => user.phone,
               "listings" => [
                 %{"id" => to_string(listing1.id)}
               ],
               "favorites" => [
                 %{"id" => to_string(favorited_listing1.id)}
               ]
             } == json_response(conn, 200)["data"]["userProfile"]
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

      variables = %{
        "id" => user.id,
        "listingPagination" => %{
          "pageSize" => 1
        },
        "listingFilters" => %{
          "types" => ["Casa"]
        },
        "favoritesPagination" => %{
          "pageSize" => 1
        },
        "favoritesFilters" => %{
          "types" => ["Casa"]
        }
      }

      query = """
        query UserProfile(
          $id: ID,
          $listingPagination: ListingPagination,
          $listingFilters: ListingFilterInput,
          $favoritesPagination: ListingPagination,
          $favoritesFilters: ListingFilterInput
          ) {
          userProfile(id: $id) {
            id
            name
            email
            phone
            listings (
              pagination: $listingPagination
              filters: $listingFilters
            ) {
              id
            }
            favorites (
              pagination: $favoritesPagination
              filters: $favoritesFilters
            ) {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "id" => to_string(user.id),
               "name" => user.name,
               "email" => user.email,
               "phone" => user.phone,
               "listings" => [
                 %{"id" => to_string(listing1.id)}
               ],
               "favorites" => [
                 %{"id" => to_string(favorited_listing1.id)}
               ]
             } == json_response(conn, 200)["data"]["userProfile"]
    end

    test "user should get his own profile without passing id as parameter", %{
      user_conn: conn,
      user_user: user
    } do
      query = """
        query UserProfile {
          userProfile {
            id
            name
            email
            phone
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert %{
               "id" => to_string(user.id),
               "name" => user.name,
               "email" => user.email,
               "phone" => user.phone
             } == json_response(conn, 200)["data"]["userProfile"]
    end

    test "anonymous should not get user profile", %{unauthenticated_conn: conn} do
      user =
        insert(:user, name: "Tester John", email: "tester.john@emcasa.com", phone: "123456789")

      variables = %{"id" => user.id}

      query = """
        query UserProfile($id: ID) {
          userProfile(ID: $id) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end

    test "user should not get other user's profile", %{user_conn: conn} do
      user =
        insert(:user, name: "Tester John", email: "tester.john@emcasa.com", phone: "123456789")

      variables = %{"id" => user.id}

      query = """
        query UserProfile($id: ID) {
          userProfile(ID: $id) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end

    test "user should see its inactive listings", %{user_conn: conn, user_user: user} do
      listing1 = insert(:listing, user: user, type: "Casa", score: 4)
      listing2 = insert(:listing, user: user, type: "Casa", score: 3)
      listing3 = insert(:listing, user: user, type: "Apartamento", score: 2, status: "inactive")

      variables = %{
        "id" => user.id,
        "listingPagination" => %{},
        "listingFilters" => %{}
      }

      query = """
        query UserProfile(
          $id: ID,
          $listingPagination: ListingPagination,
          $listingFilters: ListingFilterInput
          ) {
          userProfile(id: $id) {
            id
            listings (
              pagination: $listingPagination
              filters: $listingFilters
            ) {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "id" => to_string(user.id),
               "listings" => [
                 %{"id" => to_string(listing1.id)},
                 %{"id" => to_string(listing2.id)},
                 %{"id" => to_string(listing3.id)}
               ]
             } == json_response(conn, 200)["data"]["userProfile"]
    end
  end

  describe "users" do
    @tag dev: true
    test "for admin list all users", %{admin_conn: conn, admin_user: admin, user_user: user} do
      query = """
        query Users {
          users {
            id
            name
            phone
            role
         }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert [
               %{
                 "id" => to_string(admin.id),
                 "name" => admin.name,
                 "phone" => admin.phone,
                 "role" => admin.role
               },
               %{
                 "id" => to_string(user.id),
                 "name" => user.name,
                 "phone" => user.phone,
                 "role" => user.role
               }
             ] ==
               json_response(conn, 200)["data"]["users"]
    end
  end
end
