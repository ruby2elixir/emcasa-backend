defmodule ReWeb.GraphQL.Developments.QueryTest do
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

  describe "developments" do
    @developments_query """
    query Developments {
      developments {
        uuid
        name
        title
        phase
        builder
        description
      }
    }
    """

    test "admin should query developments", %{admin_conn: conn} do
      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@developments_query))

      assert json_response(conn, 200)["data"] == %{"developments" => []}
    end

    test "user should query developments", %{user_conn: conn} do
      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@developments_query))

      assert json_response(conn, 200)["data"] == %{"developments" => []}
    end

    test "anonymous should query developments", %{unauthenticated_conn: conn} do
      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@developments_query))

      assert json_response(conn, 200)["data"] == %{"developments" => []}
    end
  end

  describe "development" do
    @tag dev: true
    test "admin should query development", %{admin_conn: conn} do
      %{filename: image_filename1} = image1 = insert(:image, is_active: true, position: 1)
      %{filename: image_filename2} = image2 = insert(:image, is_active: true, position: 2)

      %{id: address_id, street: street, street_number: street_number} = insert(:address)

      %{
        uuid: development_uuid,
        name: name,
        title: title,
        phase: phase,
        builder: builder,
        description: description
      } = insert(:development, address_id: address_id, images: [image1, image2])

      variables = %{
        "uuid" => development_uuid
      }

      query = """
        query Development (
          $uuid: UUID!,
          ) {
          development (uuid: $uuid) {
            name
            title
            phase
            builder
            description
            address {
              street_number
              street
            }
            images {
              filename
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "name" => name,
               "title" => title,
               "phase" => phase,
               "builder" => builder,
               "description" => description,
               "address" => %{
                 "street_number" => street_number,
                 "street" => street
               },
               "images" => [
                 %{"filename" => image_filename1},
                 %{"filename" => image_filename2}
               ]
             } == json_response(conn, 200)["data"]["development"]
    end

    test "user should query development", %{user_conn: conn} do
      %{filename: image_filename1} = image1 = insert(:image, is_active: true, position: 1)
      %{filename: image_filename2} = image2 = insert(:image, is_active: true, position: 2)

      %{id: address_id, street: street} = insert(:address)

      %{
        uuid: development_uuid,
        name: name,
        title: title,
        phase: phase,
        builder: builder,
        description: description
      } = insert(:development, address_id: address_id, images: [image1, image2])

      variables = %{
        "uuid" => development_uuid
      }

      query = """
        query Development (
          $uuid: UUID!,
          ) {
          development (uuid: $uuid) {
            name
            title
            phase
            builder
            description
            address {
              street_number
              street
            }
            images {
              filename
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "name" => name,
               "title" => title,
               "phase" => phase,
               "builder" => builder,
               "description" => description,
               "address" => %{
                 "street_number" => nil,
                 "street" => street
               },
               "images" => [
                 %{"filename" => image_filename1},
                 %{"filename" => image_filename2}
               ]
             } == json_response(conn, 200)["data"]["development"]
    end

    test "unauthenticated user should query development", %{unauthenticated_conn: conn} do
      %{filename: image_filename1} = image1 = insert(:image, is_active: true, position: 1)
      %{filename: image_filename2} = image2 = insert(:image, is_active: true, position: 2)

      %{id: address_id, street: street} = insert(:address)

      %{
        uuid: development_uuid,
        name: name,
        title: title,
        phase: phase,
        builder: builder,
        description: description
      } = insert(:development, address_id: address_id, images: [image1, image2])

      variables = %{
        "uuid" => development_uuid
      }

      query = """
        query Development (
          $uuid: UUID!,
          ) {
          development (uuid: $uuid) {
            name
            title
            phase
            builder
            description
            address {
              street_number
              street
            }
            images {
              filename
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "name" => name,
               "title" => title,
               "phase" => phase,
               "builder" => builder,
               "description" => description,
               "address" => %{
                 "street_number" => nil,
                 "street" => street
               },
               "images" => [
                 %{"filename" => image_filename1},
                 %{"filename" => image_filename2}
               ]
             } == json_response(conn, 200)["data"]["development"]
    end
  end
end
