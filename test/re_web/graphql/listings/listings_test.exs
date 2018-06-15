defmodule ReWeb.GraphQL.Listings.ListingsTest do
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

  describe "listings" do
    test "admin should query listings", %{admin_conn: conn} do
      user = insert(:user)

      insert(
        :listing,
        address: build(:address, street_number: "12B"),
        images: [
          build(:image, filename: "test.jpg", position: 3),
          build(:image, filename: "test2.jpg", position: 2, is_active: false),
          build(:image, filename: "test3.jpg", position: 1)
        ],
        user: user
      )

      insert(:image, filename: "not_in_listing_image.jpg")

      query = """
        {
          listings {
            listings {
              address {
                street_number
              }
              activeImages: images (isActive: true, limit: 1) {
                filename
              }
              twoImages: images (limit: 2) {
                filename
              }
              inactiveImages: images (isActive: false) {
                filename
              }
              owner {
                name
              }
            }
            remaining_count
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listings"))

      name = user.name

      assert %{"listings" => %{
               "listings" => [
                 %{
                   "address" => %{"street_number" => "12B"},
                   "activeImages" => [%{"filename" => "test3.jpg"}],
                   "twoImages" => [%{"filename" => "test3.jpg"}, %{"filename" => "test2.jpg"}],
                   "inactiveImages" => [%{"filename" => "test2.jpg"}],
                   "owner" => %{"name" => ^name}
                 }
               ],
               "remaining_count" => 0
             }
             } = json_response(conn, 200)["data"]
    end

    test "owner should query listings", %{user_conn: conn, user_user: user} do
      insert(
        :listing,
        address: build(:address, street_number: "12B"),
        images: [
          build(:image, filename: "test.jpg"),
          build(:image, filename: "test2.jpg", is_active: false)
        ],
        user: user
      )

      insert(:image, filename: "not_in_listing_image.jpg")

      query = """
        {
          listings {
            listings {
              address {
                street_number
              }
              activeImages: images (isActive: true) {
                filename
              }
              inactiveImages: images (isActive: false) {
                filename
              }
              owner {
                name
              }
            }
            remaining_count
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listings"))

      name = user.name

      assert %{"listings" => %{
               "listings" => [
                 %{
                   "address" => %{"street_number" => "12B"},
                   "activeImages" => [%{"filename" => "test.jpg"}],
                   "inactiveImages" => [%{"filename" => "test2.jpg"}],
                   "owner" => %{"name" => ^name}
                 }
               ],
               "remaining_count" => 0
             }
             } = json_response(conn, 200)["data"]
    end

    test "user should query listings", %{user_conn: conn} do
      user = insert(:user)

      insert(
        :listing,
        address: build(:address, street_number: "12B"),
        images: [
          build(:image, filename: "test.jpg"),
          build(:image, filename: "test2.jpg", is_active: false)
        ],
        user: user
      )

      insert(:image, filename: "not_in_listing_image.jpg")

      query = """
        {
          listings {
            listings {
              address {
                street_number
              }
              activeImages: images (isActive: true) {
                filename
              }
              inactiveImages: images (isActive: false) {
                filename
              }
              owner {
                name
              }
            }
            remaining_count
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listings"))

      assert %{"listings" => %{
               "listings" => [
                 %{
                   "address" => %{"street_number" => nil},
                   "activeImages" => [%{"filename" => "test.jpg"}],
                   "inactiveImages" => [%{"filename" => "test.jpg"}],
                   "owner" => nil
                 }
               ],
               "remaining_count" => 0
             }
             } = json_response(conn, 200)["data"]
    end

    test "anonymous should query listings", %{unauthenticated_conn: conn} do
      user = insert(:user)

      insert(
        :listing,
        address: build(:address, street_number: "12B"),
        images: [
          build(:image, filename: "test.jpg"),
          build(:image, filename: "test2.jpg", is_active: false)
        ],
        user: user
      )

      insert(:image, filename: "not_in_listing_image.jpg")

      query = """
        {
          listings {
            listings {
              address {
                street_number
              }
              activeImages: images (isActive: true) {
                filename
              }
              inactiveImages: images (isActive: false) {
                filename
              }
              owner {
                name
              }
            }
            remaining_count
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listings"))

      assert %{"listings" => %{
               "listings" => [
                 %{
                   "address" => %{"street_number" => nil},
                   "activeImages" => [%{"filename" => "test.jpg"}],
                   "inactiveImages" => [%{"filename" => "test.jpg"}],
                   "owner" => nil
                 }
               ],
               "remaining_count" => 0
             }
             } = json_response(conn, 200)["data"]
    end
  end
end
