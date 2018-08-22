defmodule ReWeb.GraphQL.Featured.QueryTest do
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

  test "should query featured for admin", %{admin_conn: conn} do
    insert(
      :listing,
      address: build(:address, street: "Street A"),
      score: 4,
      images: [build(:image, filename: "test1.jpg")]
    )

    insert(
      :listing,
      address: build(:address, street: "Street B"),
      score: 3,
      images: [build(:image, filename: "test2.jpg")]
    )

    insert(
      :listing,
      address: build(:address, street: "Street C"),
      score: 2,
      images: [build(:image, filename: "test3.jpg")]
    )

    insert(
      :listing,
      address: build(:address, street: "Street D"),
      score: 1,
      images: [build(:image, filename: "test4.jpg")]
    )

    query = """
      query FeaturedListing {
        featuredListings {
          address {
            street
          }
          images {
            filename
          }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert [
             %{
               "address" => %{"street" => "Street A"},
               "images" => [%{"filename" => "test1.jpg"}]
             },
             %{
               "address" => %{"street" => "Street B"},
               "images" => [%{"filename" => "test2.jpg"}]
             },
             %{
               "address" => %{"street" => "Street C"},
               "images" => [%{"filename" => "test3.jpg"}]
             },
             %{
               "address" => %{"street" => "Street D"},
               "images" => [%{"filename" => "test4.jpg"}]
             }
           ] == json_response(conn, 200)["data"]["featuredListings"]
  end

  test "should query featured for user", %{user_conn: conn} do
    insert(
      :listing,
      address: build(:address, street: "Street A"),
      score: 4,
      images: [build(:image, filename: "test1.jpg")]
    )

    insert(
      :listing,
      address: build(:address, street: "Street B"),
      score: 3,
      images: [build(:image, filename: "test2.jpg")]
    )

    insert(
      :listing,
      address: build(:address, street: "Street C"),
      score: 2,
      images: [build(:image, filename: "test3.jpg")]
    )

    insert(
      :listing,
      address: build(:address, street: "Street D"),
      score: 1,
      images: [build(:image, filename: "test4.jpg")]
    )

    query = """
      query FeaturedListing {
        featuredListings {
          address {
            street
          }
          images {
            filename
          }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert [
             %{
               "address" => %{"street" => "Street A"},
               "images" => [%{"filename" => "test1.jpg"}]
             },
             %{
               "address" => %{"street" => "Street B"},
               "images" => [%{"filename" => "test2.jpg"}]
             },
             %{
               "address" => %{"street" => "Street C"},
               "images" => [%{"filename" => "test3.jpg"}]
             },
             %{
               "address" => %{"street" => "Street D"},
               "images" => [%{"filename" => "test4.jpg"}]
             }
           ] == json_response(conn, 200)["data"]["featuredListings"]
  end

  test "should query featured for anonymous", %{unauthenticated_conn: conn} do
    insert(
      :listing,
      address: build(:address, street: "Street A"),
      score: 4,
      images: [build(:image, filename: "test1.jpg")]
    )

    insert(
      :listing,
      address: build(:address, street: "Street B"),
      score: 3,
      images: [build(:image, filename: "test2.jpg")]
    )

    insert(
      :listing,
      address: build(:address, street: "Street C"),
      score: 2,
      images: [build(:image, filename: "test3.jpg")]
    )

    insert(
      :listing,
      address: build(:address, street: "Street D"),
      score: 1,
      images: [build(:image, filename: "test4.jpg")]
    )

    query = """
      query FeaturedListing {
        featuredListings {
          address {
            street
          }
          images {
            filename
          }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert [
             %{
               "address" => %{"street" => "Street A"},
               "images" => [%{"filename" => "test1.jpg"}]
             },
             %{
               "address" => %{"street" => "Street B"},
               "images" => [%{"filename" => "test2.jpg"}]
             },
             %{
               "address" => %{"street" => "Street C"},
               "images" => [%{"filename" => "test3.jpg"}]
             },
             %{
               "address" => %{"street" => "Street D"},
               "images" => [%{"filename" => "test4.jpg"}]
             }
           ] == json_response(conn, 200)["data"]["featuredListings"]
  end
end
