defmodule ReWeb.GraphQL.Images.InsertTest do
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

  test "admin should insert image", %{admin_conn: conn} do
    %{id: listing_id} = insert(:listing)

    mutation = """
      mutation {
        insertImage(input: {
          listingId: #{listing_id},
          filename: "test.jpg"
        }) {
          description
          filename
          isActive
          position
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{
             "insertImage" => %{
               "description" => nil,
               "filename" => "test.jpg",
               "isActive" => true,
               "position" => 1
             }
           } = json_response(conn, 200)["data"]
  end

  test "owner should insert image", %{user_conn: conn, user_user: user} do
    %{id: listing_id} = insert(:listing, user: user)

    mutation = """
      mutation {
        insertImage(input: {
          listingId: #{listing_id},
          filename: "test.jpg"
        }) {
          description
          filename
          isActive
          position
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{
             "insertImage" => %{
               "description" => nil,
               "filename" => "test.jpg",
               "isActive" => true,
               "position" => 1
             }
           } = json_response(conn, 200)["data"]
  end

  test "user should not insert image if not owner", %{user_conn: conn, admin_user: user} do
    %{id: listing_id} = insert(:listing, user: user)

    mutation = """
      mutation {
        insertImage(input: {
          listingId: #{listing_id},
          filename: "test.jpg"
        }) {
          description
          filename
          isActive
          position
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert [%{"message" => "forbidden"}] = json_response(conn, 200)["errors"]
  end

  test "anonymous should not insert image", %{unauthenticated_conn: conn} do
    %{id: listing_id} = insert(:listing)

    mutation = """
      mutation {
        insertImage(input: {
          listingId: #{listing_id},
          filename: "test.jpg"
        }) {
          description
          filename
          isActive
          position
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert [%{"message" => "unauthorized"}] = json_response(conn, 200)["errors"]
  end
end
