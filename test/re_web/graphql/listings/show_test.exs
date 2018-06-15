defmodule ReWeb.GraphQL.Listings.ShowTest do
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

  test "admin should query listing show", %{admin_conn: conn} do
    active_images = insert_list(3, :image, is_active: true)
    inactive_images = insert_list(2, :image, is_active: false)
    %{street: street, street_number: street_number} = address = insert(:address)
    user = insert(:user)
    interests = insert_list(3, :interest)
    in_person_visits = insert_list(3, :in_person_visit)
    listings_favorites = insert_list(3, :listings_favorites)
    tour_visualisations = insert_list(3, :tour_visualisation)
    listings_visualisations = insert_list(3, :listing_visualisation)

    %{id: listing_id} =
      insert(:listing, address: address, images: active_images ++ inactive_images, user: user, interests: interests, in_person_visits: in_person_visits, listings_favorites: listings_favorites, tour_visualisations: tour_visualisations, listings_visualisations: listings_visualisations)

    query = """
      {
        listing (id: #{listing_id}) {
          address {
            street
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
          interestCount
          inPersonVisitCount
          listingFavoriteCount
          tourVisualisationCount
          listingVisualisationCount
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listing"))

    name = user.name

    assert %{
             "listing" => %{
               "address" => %{"street" => ^street, "street_number" => ^street_number},
               "activeImages" => [_, _, _],
               "inactiveImages" => [_, _],
               "owner" => %{"name" => ^name},
               "interestCount" => 3,
               "inPersonVisitCount" => 3,
               "listingFavoriteCount" => 3,
               "tourVisualisationCount" => 3,
               "listingVisualisationCount" => 3
             }
           } = json_response(conn, 200)["data"]
  end

  test "owner should query listing show", %{user_conn: conn, user_user: user} do
    active_images = insert_list(3, :image, is_active: true)
    inactive_images = insert_list(2, :image, is_active: false)
    %{street: street, street_number: street_number} = address = insert(:address)

    interests = insert_list(3, :interest)
    in_person_visits = insert_list(3, :in_person_visit)
    listings_favorites = insert_list(3, :listings_favorites)
    tour_visualisations = insert_list(3, :tour_visualisation)
    listings_visualisations = insert_list(3, :listing_visualisation)

    %{id: listing_id} =
      insert(:listing, address: address, images: active_images ++ inactive_images, user: user, interests: interests, in_person_visits: in_person_visits, listings_favorites: listings_favorites, tour_visualisations: tour_visualisations, listings_visualisations: listings_visualisations)

    query = """
      {
        listing (id: #{listing_id}) {
          address {
            street
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
          interestCount
          inPersonVisitCount
          listingFavoriteCount
          tourVisualisationCount
          listingVisualisationCount
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listing"))

    name = user.name

    assert %{
             "listing" => %{
               "address" => %{"street" => ^street, "street_number" => ^street_number},
               "activeImages" => [_, _, _],
               "inactiveImages" => [_, _],
               "owner" => %{"name" => ^name},
               "interestCount" => 3,
               "inPersonVisitCount" => 3,
               "listingFavoriteCount" => 3,
               "tourVisualisationCount" => 3,
               "listingVisualisationCount" => 3
             }
           } = json_response(conn, 200)["data"]
  end

  test "user should query listing show", %{user_conn: conn} do
    active_images = insert_list(3, :image, is_active: true)
    inactive_images = insert_list(2, :image, is_active: false)
    %{street: street} = address = insert(:address)
    user = insert(:user)

    %{id: listing_id} =
      insert(:listing, address: address, images: active_images ++ inactive_images, user: user)

    query = """
      {
        listing (id: #{listing_id}) {
          address {
            street
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
          interestCount
          inPersonVisitCount
          listingFavoriteCount
          tourVisualisationCount
          listingVisualisationCount
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listing"))

    assert %{
             "listing" => %{
               "address" => %{"street" => ^street, "street_number" => nil},
               "activeImages" => [_, _, _],
               "inactiveImages" => [_, _, _],
               "owner" => nil,
               "interestCount" => nil,
               "inPersonVisitCount" => nil,
               "listingFavoriteCount" => nil,
               "tourVisualisationCount" => nil,
               "listingVisualisationCount" => nil
             }
           } = json_response(conn, 200)["data"]
  end

  test "anonymous should query listing show", %{unauthenticated_conn: conn} do
    active_images = insert_list(3, :image, is_active: true)
    inactive_images = insert_list(2, :image, is_active: false)
    %{street: street} = address = insert(:address)
    user = insert(:user)

    %{id: listing_id} =
      insert(:listing, address: address, images: active_images ++ inactive_images, user: user)

    query = """
      {
        listing (id: #{listing_id}) {
          address {
            street
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
          interestCount
          inPersonVisitCount
          listingFavoriteCount
          tourVisualisationCount
          listingVisualisationCount
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listing"))

    assert %{
             "listing" => %{
               "address" => %{"street" => ^street, "street_number" => nil},
               "activeImages" => [_, _, _],
               "inactiveImages" => [_, _, _],
               "owner" => nil,
               "interestCount" => nil,
               "inPersonVisitCount" => nil,
               "listingFavoriteCount" => nil,
               "tourVisualisationCount" => nil,
               "listingVisualisationCount" => nil
             }
           } = json_response(conn, 200)["data"]
  end
end
