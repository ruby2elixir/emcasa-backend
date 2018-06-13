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
      insert(
        :listing,
        address: build(:address, street_number: "12B"),
        images: [
          build(:image, filename: "test.jpg"),
          build(:image, filename: "test2.jpg", is_active: false)
        ]
      )

      insert(:image, filename: "not_in_listing_image.jpg")

      query = """
        {
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
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listings"))

      assert %{
               "listings" => [
                 %{
                   "address" => %{"street_number" => "12B"},
                   "activeImages" => [%{"filename" => "test.jpg"}],
                   "inactiveImages" => [%{"filename" => "test2.jpg"}]
                 }
               ]
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
            address {
              street_number
            }
            activeImages: images (isActive: true) {
              filename
            }
            inactiveImages: images (isActive: false) {
              filename
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listings"))

      assert %{
               "listings" => [
                 %{
                   "address" => %{"street_number" => "12B"},
                   "activeImages" => [%{"filename" => "test.jpg"}],
                   "inactiveImages" => [%{"filename" => "test2.jpg"}]
                 }
               ]
             } = json_response(conn, 200)["data"]
    end

    test "user should query listings", %{user_conn: conn} do
      insert(
        :listing,
        address: build(:address, street_number: "12B"),
        images: [
          build(:image, filename: "test.jpg"),
          build(:image, filename: "test2.jpg", is_active: false)
        ]
      )

      insert(:image, filename: "not_in_listing_image.jpg")

      query = """
        {
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
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listings"))

      assert %{
               "listings" => [
                 %{
                   "address" => %{"street_number" => nil},
                   "activeImages" => [%{"filename" => "test.jpg"}],
                   "inactiveImages" => [%{"filename" => "test.jpg"}]
                 }
               ]
             } = json_response(conn, 200)["data"]
    end
  end
end
