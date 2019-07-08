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
    test "admin should query development", %{admin_conn: conn} do
      %{filename: image_filename1} = image1 = insert(:image, is_active: true, position: 1)
      %{filename: image_filename2} = image2 = insert(:image, is_active: true, position: 2)

      %{id: address_id, street: street, street_number: street_number} = insert(:address)

      listing = insert(:listing)

      %{
        uuid: development_uuid,
        name: name,
        phase: phase,
        builder: builder,
        description: description
      } =
        insert(
          :development,
          address_id: address_id,
          images: [image1, image2],
          listings: [listing]
        )

      variables = %{
        "uuid" => development_uuid
      }

      query = """
        query Development (
          $uuid: UUID!,
          ) {
          development (uuid: $uuid) {
            name
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
            listings {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "name" => name,
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
               ],
               "listings" => [
                 %{"id" => to_string(listing.id)}
               ]
             } == json_response(conn, 200)["data"]["development"]
    end

    test "admin should query listings's development with filters", %{admin_conn: conn} do
      listing_1 = insert(:listing, price: 1_000_000)
      listing_2 = insert(:listing, price: 2_000_000)

      %{uuid: development_uuid} = insert(:development, listings: [listing_1, listing_2])

      variables = %{
        "uuid" => development_uuid,
        "filters" => %{
          "maxPrice" => 1_500_000
        }
      }

      query = """
        query Development (
          $uuid: UUID!,
          $filters: ListingFilterInput
          ) {
          development (uuid: $uuid) {
            listings(filters: $filters) {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "listings" => [
                 %{"id" => to_string(listing_1.id)}
               ]
             } == json_response(conn, 200)["data"]["development"]
    end

    test "user should query development", %{user_conn: conn} do
      %{filename: image_filename1} = image1 = insert(:image, is_active: true, position: 1)
      %{filename: image_filename2} = image2 = insert(:image, is_active: true, position: 2)

      %{id: address_id, street: street} = insert(:address)

      listing = insert(:listing)

      %{
        uuid: development_uuid,
        name: name,
        phase: phase,
        builder: builder,
        description: description
      } =
        insert(
          :development,
          address_id: address_id,
          images: [image1, image2],
          listings: [listing]
        )

      variables = %{
        "uuid" => development_uuid
      }

      query = """
        query Development (
          $uuid: UUID!,
          ) {
          development (uuid: $uuid) {
            name
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
            listings {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "name" => name,
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
               ],
               "listings" => [
                 %{"id" => to_string(listing.id)}
               ]
             } == json_response(conn, 200)["data"]["development"]
    end

    test "unauthenticated user should query development", %{unauthenticated_conn: conn} do
      %{filename: image_filename1} = image1 = insert(:image, is_active: true, position: 1)
      %{filename: image_filename2} = image2 = insert(:image, is_active: true, position: 2)

      %{id: address_id, street: street} = insert(:address)

      listing = insert(:listing)

      %{
        uuid: development_uuid,
        name: name,
        phase: phase,
        builder: builder,
        description: description
      } =
        insert(
          :development,
          address_id: address_id,
          images: [image1, image2],
          listings: [listing]
        )

      variables = %{
        "uuid" => development_uuid
      }

      query = """
        query Development (
          $uuid: UUID!,
          ) {
          development (uuid: $uuid) {
            name
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
            listings {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "name" => name,
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
               ],
               "listings" => [
                 %{"id" => to_string(listing.id)}
               ]
             } == json_response(conn, 200)["data"]["development"]
    end
  end

  describe "typologies" do
    test "should group typologies by area and rooms count", %{user_conn: conn} do
      development = insert(:development)
      typologies = Enum.sort([
        %{"rooms" => 2, "area" => 100, "unitCount" => 1},
        %{"rooms" => 3, "area" => 100, "unitCount" => 2},
        %{"rooms" => 3, "area" => 150, "unitCount" => 3}
      ])
      Enum.each(typologies, fn %{
        "rooms" => rooms,
        "area" => area,
        "unitCount" => unitCount
      } ->
        insert_list(unitCount, :listing, rooms: rooms, area: area, status: "active", development: development)
      end)
      variables = %{uuid: development.uuid}

      query = """
        query Development(
          $uuid: UUID!
        ) {
          development (uuid: $uuid) {
            typologies {
              rooms
              area
              unitCount
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert typologies == Enum.sort(json_response(conn, 200)["data"]["development"]["typologies"])
    end
  end
end
