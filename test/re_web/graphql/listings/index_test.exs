defmodule ReWeb.GraphQL.Listings.IndexTest do
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

  test "admin should query listing index", %{admin_conn: conn} do
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

    assert %{
             "listings" => %{
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

  test "owner should query listing index", %{user_conn: conn, user_user: user} do
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

    assert %{
             "listings" => %{
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

  test "user should query listing index", %{user_conn: conn} do
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

    assert %{
             "listings" => %{
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

  test "anonymous should query listing index", %{unauthenticated_conn: conn} do
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

    assert %{
             "listings" => %{
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

  test "should query listing index with pagination", %{unauthenticated_conn: conn} do
    listing1 = insert(:listing, score: 4, price: 950_000, rooms: 3, area: 90)
    [%{id: listing2_id}, %{id: listing3_id}] = insert_list(2, :listing, score: 4)
    insert_list(3, :listing, score: 3)

    pagination_input = "{pageSize: 1, excludedListingIds: [#{listing2_id}, #{listing3_id}]}"

    query = """
      {
        listings (pagination: #{pagination_input}) {
          listings {
            id
          }
          remaining_count
        }
      }
    """

    listing1_id = to_string(listing1.id)

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listings"))

    assert %{
             "listings" => %{
               "listings" => [
                 %{
                   "id" => ^listing1_id
                 }
               ],
               "remaining_count" => 3
             }
           } = json_response(conn, 200)["data"]
  end

  test "should query listing index with filtering", %{user_conn: conn, user_user: user} do
    insert(
      :listing,
      price: 1_100_000,
      rooms: 3,
      area: 90,
      type: "Apartamento",
      address:
        build(
          :address,
          neighborhood: "Copacabana",
          neighborhood_slug: "copacabana",
          lat: 50.0,
          lng: 50.0
        ),
      garage_spots: 2
    )

    insert(
      :listing,
      price: 790_000,
      rooms: 3,
      area: 90,
      type: "Apartamento",
      address:
        build(
          :address,
          neighborhood: "Copacabana",
          neighborhood_slug: "copacabana",
          lat: 50.0,
          lng: 50.0
        ),
      garage_spots: 2
    )

    insert(
      :listing,
      price: 900_000,
      rooms: 5,
      area: 90,
      type: "Apartamento",
      address:
        build(
          :address,
          neighborhood: "Copacabana",
          neighborhood_slug: "copacabana",
          lat: 50.0,
          lng: 50.0
        ),
      garage_spots: 2
    )

    insert(
      :listing,
      price: 900_000,
      rooms: 1,
      area: 90,
      type: "Apartamento",
      address:
        build(
          :address,
          neighborhood: "Copacabana",
          neighborhood_slug: "copacabana",
          lat: 50.0,
          lng: 50.0
        ),
      garage_spots: 2
    )

    insert(
      :listing,
      price: 900_000,
      rooms: 3,
      area: 110,
      type: "Apartamento",
      address:
        build(
          :address,
          neighborhood: "Copacabana",
          neighborhood_slug: "copacabana",
          lat: 50.0,
          lng: 50.0
        ),
      garage_spots: 2
    )

    insert(
      :listing,
      price: 900_000,
      rooms: 3,
      area: 70,
      type: "Apartamento",
      address:
        build(
          :address,
          neighborhood: "Copacabana",
          neighborhood_slug: "copacabana",
          lat: 50.0,
          lng: 50.0
        ),
      garage_spots: 2
    )

    insert(
      :listing,
      price: 900_000,
      rooms: 3,
      area: 90,
      type: "Apartamento",
      address:
        build(
          :address,
          neighborhood: "Botafogo",
          neighborhood_slug: "botafogo",
          lat: 50.0,
          lng: 50.0
        ),
      garage_spots: 2
    )

    insert(
      :listing,
      price: 900_000,
      rooms: 3,
      area: 90,
      type: "Casa",
      address:
        build(
          :address,
          neighborhood: "Copacabana",
          neighborhood_slug: "copacabana",
          lat: 50.0,
          lng: 50.0
        ),
      garage_spots: 2
    )

    insert(
      :listing,
      price: 900_000,
      rooms: 3,
      area: 90,
      type: "Apartamento",
      address:
        build(
          :address,
          neighborhood: "Copacabana",
          neighborhood_slug: "copacabana",
          lat: 70.0,
          lng: 50.0
        ),
      garage_spots: 2
    )

    insert(
      :listing,
      price: 900_000,
      rooms: 3,
      area: 90,
      type: "Apartamento",
      address:
        build(
          :address,
          neighborhood: "Copacabana",
          neighborhood_slug: "copacabana",
          lat: 30.0,
          lng: 50.0
        ),
      garage_spots: 2
    )

    insert(
      :listing,
      price: 900_000,
      rooms: 3,
      area: 90,
      type: "Apartamento",
      address:
        build(
          :address,
          neighborhood: "Copacabana",
          neighborhood_slug: "copacabana",
          lat: 50.0,
          lng: 70.0
        ),
      garage_spots: 2
    )

    insert(
      :listing,
      price: 900_000,
      rooms: 3,
      area: 90,
      type: "Apartamento",
      address:
        build(
          :address,
          neighborhood: "Copacabana",
          neighborhood_slug: "copacabana",
          lat: 50.0,
          lng: 30.0
        ),
      garage_spots: 2
    )

    insert(
      :listing,
      price: 900_000,
      rooms: 3,
      area: 90,
      type: "Apartamento",
      address:
        build(
          :address,
          neighborhood: "Copacabana",
          neighborhood_slug: "copacabana",
          lat: 50.0,
          lng: 50.0
        ),
      garage_spots: 0
    )

    insert(
      :listing,
      price: 900_000,
      rooms: 3,
      area: 90,
      type: "Apartamento",
      address:
        build(
          :address,
          neighborhood: "Copacabana",
          neighborhood_slug: "copacabana",
          lat: 50.0,
          lng: 50.0
        ),
      garage_spots: 4
    )

    listing1 =
      insert(
        :listing,
        price: 900_000,
        rooms: 3,
        area: 90,
        type: "Apartamento",
        address:
          build(
            :address,
            neighborhood: "Copacabana",
            neighborhood_slug: "copacabana",
            lat: 50.0,
            lng: 50.0
          ),
        garage_spots: 2
      )

    listing2 =
      insert(
        :listing,
        price: 900_000,
        rooms: 3,
        area: 90,
        type: "Apartamento",
        address:
          build(
            :address,
            neighborhood: "Copacabana",
            neighborhood_slug: "copacabana",
            lat: 50.0,
            lng: 50.0
          ),
        garage_spots: 2
      )

    insert(:listing_blacklist, listing: listing2, user: user)

    filter_input = """
      {
        maxPrice: 1000000
        minPrice: 800000
        maxRooms: 4
        minRooms: 2
        minArea: 80
        maxArea: 100
        neighborhoods: ["Copacabana", "Leblon"]
        types: ["Apartamento"]
        maxLat: 60.0
        minLat: 40.0
        maxLng: 60.0
        minLng: 40.0
        neighborhoodsSlugs: ["copacabana", "leblon"]
        maxGarageSpots: 3
        minGarageSpots: 1
      }
    """

    query = """
      {
        listings (filters: #{filter_input}) {
          listings {
            id
          }
          filters {
            maxPrice
          }
        }
      }
    """

    listing1_id = to_string(listing1.id)

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listings"))

    assert %{
             "listings" => %{
               "listings" => [
                 %{
                   "id" => ^listing1_id
                 }
               ],
               "filters" => %{
                 "maxPrice" => 1_000_000
               }
             }
           } = json_response(conn, 200)["data"]
  end

  test "should query listing index with order by", %{user_conn: conn} do
    %{id: id1} = insert(:listing, garage_spots: 1, price: 1_000_000, rooms: 2)
    %{id: id2} = insert(:listing, garage_spots: 2, price: 900_000, rooms: 3, score: 4)
    %{id: id3} = insert(:listing, garage_spots: 3, price: 1_100_000, rooms: 4)
    %{id: id4} = insert(:listing, garage_spots: 2, price: 1_000_000, rooms: 3)
    %{id: id5} = insert(:listing, garage_spots: 2, price: 900_000, rooms: 3, score: 3)
    %{id: id6} = insert(:listing, garage_spots: 3, price: 1_100_000, rooms: 5)

    order_by_input = """
      [
        {field: PRICE, type: DESC},
        {field: GARAGE_SPOTS, type: DESC},
        {field: ROOMS, type: ASC}
      ]
    """

    query = """
      {
        listings (orderBy: #{order_by_input}) {
          listings {
            id
          }
        }
      }
    """

    string_id1 = to_string(id1)
    string_id2 = to_string(id2)
    string_id3 = to_string(id3)
    string_id4 = to_string(id4)
    string_id5 = to_string(id5)
    string_id6 = to_string(id6)

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listings"))

    assert %{
             "listings" => %{
               "listings" => [
                 %{"id" => ^string_id3},
                 %{"id" => ^string_id6},
                 %{"id" => ^string_id4},
                 %{"id" => ^string_id1},
                 %{"id" => ^string_id2},
                 %{"id" => ^string_id5}
               ]
             }
           } = json_response(conn, 200)["data"]
  end

  test "should query listing index with respective images", %{unauthenticated_conn: conn} do
    insert(:listing, images: [build(:image), build(:image), build(:image)])
    insert(:listing, images: [build(:image), build(:image), build(:image)])

    query = """
      {
        listings {
          listings {
            images (limit: 2) {
              filename
            }
          }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listings"))

    assert %{
             "listings" => %{
               "listings" => [
                 %{
                   "images" => [_, _]
                 },
                 %{
                   "images" => [_, _]
                 }
               ]
             }
           } = json_response(conn, 200)["data"]
  end

  test "should query listing index with price reduction attribute", %{unauthenticated_conn: conn} do
    now = Timex.now()
    insert(:listing, score: 4, price_history: [])

    insert(
      :listing,
      price: 1_000_000,
      score: 3,
      price_history: [
        build(:price_history, price: 1_100_000, inserted_at: Timex.shift(now, weeks: -1))
      ]
    )

    insert(
      :listing,
      score: 2,
      price_history: [build(:price_history, inserted_at: Timex.shift(now, weeks: -3))]
    )

    insert(
      :listing,
      price: 1_000_000,
      score: 1,
      price_history: [
        build(:price_history, price: 900_000, inserted_at: Timex.shift(now, weeks: -1))
      ]
    )

    query = """
      {
        listings {
          listings {
            priceRecentlyReduced
          }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listings"))

    assert %{
             "listings" => %{
               "listings" => [
                 %{"priceRecentlyReduced" => false},
                 %{"priceRecentlyReduced" => true},
                 %{"priceRecentlyReduced" => false},
                 %{"priceRecentlyReduced" => false}
               ]
             }
           } = json_response(conn, 200)["data"]
  end
end
