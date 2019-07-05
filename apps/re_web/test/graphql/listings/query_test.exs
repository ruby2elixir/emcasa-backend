defmodule ReWeb.GraphQL.Listings.QueryTest do
  use ReWeb.ConnCase

  import Re.CustomAssertion

  import Re.Factory

  import Mockery

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
    test "admin should query listing index", %{admin_conn: conn} do
      user = insert(:user)

      %{uuid: uuid} =
        insert(
          :listing,
          address: build(:address, street_number: "12B"),
          images: [
            build(:image, filename: "test.jpg", position: 3),
            build(:image, filename: "test2.jpg", position: 2, is_active: false),
            build(:image, filename: "test3.jpg", position: 1)
          ],
          user: user,
          score: 4
        )

      insert(:image, filename: "not_in_listing_image.jpg")

      variables = %{
        "activeImagesIsActive" => true,
        "activeImagesLimit" => 1,
        "twoImagesLimit" => 2,
        "inactiveImagesIsActive" => false
      }

      query = """
        query Listings (
          $activeImagesIsActive: Boolean,
          $activeImagesLimit: Int,
          $twoImagesLimit: Int,
          $inactiveImagesIsActive: Int
          ) {
          listings {
            listings {
              uuid
              address {
                street_number
              }
              activeImages: images (isActive: $activeImagesIsActive, limit: $activeImagesLimit) {
                filename
              }
              twoImages: images (limit: $twoImagesLimit) {
                filename
              }
              inactiveImages: images (isActive: $inactiveImagesIsActive) {
                filename
              }
              owner {
                name
              }
              score
            }
            remaining_count
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "listings" => [
                 %{
                   "uuid" => uuid,
                   "address" => %{"street_number" => "12B"},
                   "activeImages" => [%{"filename" => "test3.jpg"}],
                   "twoImages" => [%{"filename" => "test3.jpg"}, %{"filename" => "test2.jpg"}],
                   "inactiveImages" => [%{"filename" => "test2.jpg"}],
                   "owner" => %{"name" => user.name},
                   "score" => 4
                 }
               ],
               "remaining_count" => 0
             } == json_response(conn, 200)["data"]["listings"]
    end

    test "owner should query listing index", %{user_conn: conn, user_user: user} do
      insert(
        :listing,
        address: build(:address, street_number: "12B"),
        images: [
          build(:image, filename: "test.jpg"),
          build(:image, filename: "test2.jpg", is_active: false)
        ],
        user: user,
        score: 4
      )

      insert(:image, filename: "not_in_listing_image.jpg")

      variables = %{
        "activeImagesIsActive" => true,
        "inactiveImagesIsActive" => false
      }

      query = """
        query Listings ($activeImagesIsActive: Boolean, $inactiveImagesIsActive: Boolean) {
          listings {
            listings {
              uuid
              address {
                street_number
              }
              activeImages: images (isActive: $activeImagesIsActive) {
                filename
              }
              inactiveImages: images (isActive: $inactiveImagesIsActive) {
                filename
              }
              owner {
                name
              }
              score
            }
            remaining_count
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "listings" => [
                 %{
                   "uuid" => nil,
                   "address" => %{"street_number" => "12B"},
                   "activeImages" => [%{"filename" => "test.jpg"}],
                   "inactiveImages" => [%{"filename" => "test2.jpg"}],
                   "owner" => %{"name" => user.name},
                   "score" => nil
                 }
               ],
               "remaining_count" => 0
             } == json_response(conn, 200)["data"]["listings"]
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
        user: user,
        score: 4
      )

      insert(:image, filename: "not_in_listing_image.jpg")

      variables = %{
        "activeImagesIsActive" => true,
        "inactiveImagesIsActive" => false
      }

      query = """
        query Listings ($activeImagesIsActive: Boolean, $inactiveImagesIsActive: Boolean) {
          listings {
            listings {
              uuid
              address {
                street_number
              }
              activeImages: images (isActive: $activeImagesIsActive) {
                filename
              }
              inactiveImages: images (isActive: $inactiveImagesIsActive) {
                filename
              }
              owner {
                name
              }
              score
            }
            remaining_count
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "listings" => [
                 %{
                   "uuid" => nil,
                   "address" => %{"street_number" => nil},
                   "activeImages" => [%{"filename" => "test.jpg"}],
                   "inactiveImages" => [%{"filename" => "test.jpg"}],
                   "owner" => nil,
                   "score" => nil
                 }
               ],
               "remaining_count" => 0
             } == json_response(conn, 200)["data"]["listings"]
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
        user: user,
        score: 4
      )

      insert(:image, filename: "not_in_listing_image.jpg")

      variables = %{
        "activeImagesIsActive" => true,
        "inactiveImagesIsActive" => false
      }

      query = """
        query Listings ($activeImagesIsActive: Boolean, $inactiveImagesIsActive: Boolean) {
          listings {
            listings {
              uuid
              address {
                street_number
              }
              activeImages: images (isActive: $activeImagesIsActive) {
                filename
              }
              inactiveImages: images (isActive: $inactiveImagesIsActive) {
                filename
              }
              owner {
                name
              }
              score
            }
            remaining_count
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "listings" => [
                 %{
                   "uuid" => nil,
                   "address" => %{"street_number" => nil},
                   "activeImages" => [%{"filename" => "test.jpg"}],
                   "inactiveImages" => [%{"filename" => "test.jpg"}],
                   "owner" => nil,
                   "score" => nil
                 }
               ],
               "remaining_count" => 0
             } == json_response(conn, 200)["data"]["listings"]
    end

    test "should query listing index with pagination", %{unauthenticated_conn: conn} do
      listing1 = insert(:listing, score: 4, price: 950_000, rooms: 3, area: 90)
      [%{id: listing2_id}, %{id: listing3_id}] = insert_list(2, :listing, score: 4)
      insert_list(3, :listing, score: 3)

      variables = %{
        "pagination" => %{
          "pageSize" => 1,
          "excludedListingIds" => [listing2_id, listing3_id]
        }
      }

      query = """
        query Listings ($pagination: ListingPagination) {
          listings (pagination: $pagination) {
            listings {
              id
            }
            remaining_count
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "listings" => [
                 %{
                   "id" => to_string(listing1.id)
                 }
               ],
               "remaining_count" => 3
             } == json_response(conn, 200)["data"]["listings"]
    end

    test "should query listing index with filters", %{user_conn: conn} do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "Tag 2", name_slug: "tag-2")

      insert(
        :listing,
        price: 1_100_000,
        rooms: 3,
        suites: 3,
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
        garage_spots: 2,
        garage_type: "contract",
        tags: [tag_1],
        price_per_area: 12_222.22,
        maintenance_fee: 120.0,
        is_release: false
      )

      listing1 =
        insert(
          :listing,
          price: 900_000,
          rooms: 3,
          suites: 1,
          bathrooms: 1,
          area: 90,
          type: "Apartamento",
          address:
            build(
              :address,
              neighborhood: "Copacabana",
              neighborhood_slug: "copacabana",
              state: "RJ",
              city: "Rio de Janeiro",
              state_slug: "rj",
              city_slug: "rio-de-janeiro",
              lat: 50.0,
              lng: 50.0
            ),
          garage_spots: 2,
          garage_type: "contract",
          tags: [tag_1, tag_2],
          price_per_area: 10_000.00,
          maintenance_fee: 100.0,
          is_release: true
        )

      variables = %{
        "filters" => %{
          "maxPrice" => 1_000_000,
          "minPrice" => 800_000,
          "maxPricePerArea" => 10_500,
          "minPricePerArea" => 9_500,
          "maxRooms" => 4,
          "minRooms" => 2,
          "maxSuites" => 2,
          "minSuites" => 1,
          "maxBathrooms" => 2,
          "minBathrooms" => 1,
          "minArea" => 80,
          "maxArea" => 100,
          "neighborhoods" => ["Copacabana", "Leblon"],
          "types" => ["Apartamento"],
          "maxLat" => 60.0,
          "minLat" => 40.0,
          "maxLng" => 60.0,
          "minLng" => 40.0,
          "neighborhoodsSlugs" => ["copacabana", "leblon"],
          "maxGarageSpots" => 3,
          "minGarageSpots" => 1,
          "garageTypes" => ["CONTRACT"],
          "cities" => ["Rio de Janeiro"],
          "citiesSlug" => ["rio-de-janeiro"],
          "tagsSlug" => ["tag-1", "tag-2"],
          "minMaintenanceFee" => 90.0,
          "maxMaintenanceFee" => 110.0,
          "isRelease" => true
        }
      }

      query = """
        query Listings($filters: ListingFilterInput) {
          listings (filters: $filters) {
            listings {
              id
            }
            filters {
              maxPrice
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "listings" => [
                 %{
                   "id" => to_string(listing1.id)
                 }
               ],
               "filters" => %{
                 "maxPrice" => 1_000_000
               }
             } == json_response(conn, 200)["data"]["listings"]
    end

    test "should query listing index with order by", %{user_conn: conn} do
      %{id: id1} = insert(:listing, garage_spots: 1, price: 1_000_000, rooms: 2)
      %{id: id2} = insert(:listing, garage_spots: 2, price: 900_000, rooms: 3, score: 4)
      %{id: id3} = insert(:listing, garage_spots: 3, price: 1_100_000, rooms: 4)
      %{id: id4} = insert(:listing, garage_spots: 2, price: 1_000_000, rooms: 3)
      %{id: id5} = insert(:listing, garage_spots: 2, price: 900_000, rooms: 3, score: 3)
      %{id: id6} = insert(:listing, garage_spots: 3, price: 1_100_000, rooms: 5)

      variables = %{
        "orderBy" => [
          %{"field" => "PRICE", "type" => "DESC"},
          %{"field" => "GARAGE_SPOTS", "type" => "DESC"},
          %{"field" => "ROOMS", "type" => "ASC"}
        ]
      }

      query = """
        query Listings ($orderBy: [OrderBy]) {
          listings (orderBy: $orderBy) {
            listings {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "listings" => [
                 %{"id" => to_string(id3)},
                 %{"id" => to_string(id6)},
                 %{"id" => to_string(id4)},
                 %{"id" => to_string(id1)},
                 %{"id" => to_string(id2)},
                 %{"id" => to_string(id5)}
               ]
             } == json_response(conn, 200)["data"]["listings"]
    end

    test "should query listing index with respective images", %{unauthenticated_conn: conn} do
      insert(:listing, images: [build(:image), build(:image), build(:image)])
      insert(:listing, images: [build(:image), build(:image), build(:image)])

      variables = %{
        "limit" => 2
      }

      query = """
        query Listings ($limit: Int) {
          listings {
            listings {
              images (limit: $limit) {
                filename
              }
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "listings" => [
                 %{
                   "images" => [_, _]
                 },
                 %{
                   "images" => [_, _]
                 }
               ]
             } = json_response(conn, 200)["data"]["listings"]
    end

    test "should query listing index with price reduction attribute", %{
      unauthenticated_conn: conn
    } do
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
        query Listings {
          listings {
            listings {
              priceRecentlyReduced
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      price_recently_reduced = fn items -> Enum.map(items, & &1["priceRecentlyReduced"]) end

      assert_mapper_match(
        [
          %{"priceRecentlyReduced" => false},
          %{"priceRecentlyReduced" => true},
          %{"priceRecentlyReduced" => false},
          %{"priceRecentlyReduced" => false}
        ],
        json_response(conn, 200)["data"]["listings"]["listings"],
        price_recently_reduced
      )
    end

    test "admin should query listing with all tags", %{admin_conn: conn} do
      insert(
        :listing,
        tags: [
          build(:tag, name: "Tag 1", name_slug: "tag-1", visibility: "public"),
          build(:tag, name: "Tag 2", name_slug: "tag-2", visibility: "public"),
          build(:tag, name: "Tag 3", name_slug: "tag-3", visibility: "private")
        ]
      )

      query = """
        query Listings {
          listings {
            listings {
              tags {
                nameSlug
              }
            }
          }
        }
      """

      expected = %{
        "listings" => [
          %{
            "tags" => [
              %{"nameSlug" => "tag-1"},
              %{"nameSlug" => "tag-2"},
              %{"nameSlug" => "tag-3"}
            ]
          }
        ]
      }

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert expected == json_response(conn, 200)["data"]["listings"]
    end

    test "user should query listing with publicly visible tags", %{user_conn: conn} do
      insert(
        :listing,
        tags: [
          build(:tag, name: "Tag 1", name_slug: "tag-1", visibility: "public"),
          build(:tag, name: "Tag 2", name_slug: "tag-2", visibility: "public"),
          build(:tag, name: "Tag 3", name_slug: "tag-3", visibility: "private")
        ]
      )

      query = """
        query Listings {
          listings {
            listings {
              tags {
                nameSlug
              }
            }
          }
        }
      """

      expected = %{
        "listings" => [
          %{
            "tags" => [
              %{"nameSlug" => "tag-1"},
              %{"nameSlug" => "tag-2"}
            ]
          }
        ]
      }

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert expected == json_response(conn, 200)["data"]["listings"]
    end

    test "anonymous user should query listing with publicly visible tags", %{
      unauthenticated_conn: conn
    } do
      insert(
        :listing,
        tags: [
          build(:tag, name: "Tag 1", name_slug: "tag-1", visibility: "public"),
          build(:tag, name: "Tag 2", name_slug: "tag-2", visibility: "public"),
          build(:tag, name: "Tag 3", name_slug: "tag-3", visibility: "private")
        ]
      )

      query = """
        query Listings {
          listings {
            listings {
              tags {
                nameSlug
              }
            }
          }
        }
      """

      expected = %{
        "listings" => [
          %{
            "tags" => [
              %{"nameSlug" => "tag-1"},
              %{"nameSlug" => "tag-2"}
            ]
          }
        ]
      }

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert expected == json_response(conn, 200)["data"]["listings"]
    end

    test "admin should query listing with owner contact", %{admin_conn: conn} do
      insert(
        :listing,
        owner_contact:
          build(:owner_contact, name: "Jon Snow", name_slug: "jon-snow", phone: "+5511987654321")
      )

      query = """
        query Listings {
          listings {
            listings {
              ownerContact {
                name
                phone
              }
            }
          }
        }
      """

      expected = %{
        "listings" => [
          %{
            "ownerContact" => %{"name" => "Jon Snow", "phone" => "+5511987654321"}
          }
        ]
      }

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert expected == json_response(conn, 200)["data"]["listings"]
    end

    test "user should not query listing with owner contact", %{user_conn: conn} do
      insert(
        :listing,
        owner_contact:
          build(:owner_contact, name: "Jon Snow", name_slug: "jon-snow", phone: "+5511987654321")
      )

      query = """
        query Listings {
          listings {
            listings {
              ownerContact {
                name
                phone
              }
            }
          }
        }
      """

      expected = %{
        "listings" => [
          %{
            "ownerContact" => nil
          }
        ]
      }

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert expected == json_response(conn, 200)["data"]["listings"]
    end

    test "anonymous user should not query listing with owner contact", %{
      unauthenticated_conn: conn
    } do
      insert(
        :listing,
        owner_contact:
          build(:owner_contact, name: "Jon Snow", name_slug: "jon-snow", phone: "+5511987654321")
      )

      query = """
        query Listings {
          listings {
            listings {
              ownerContact {
                name
                phone
              }
            }
          }
        }
      """

      expected = %{
        "listings" => [
          %{
            "ownerContact" => nil
          }
        ]
      }

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert expected == json_response(conn, 200)["data"]["listings"]
    end
  end

  describe "listing" do
    test "admin should query listing show", %{admin_conn: conn} do
      %{filename: active_image_filename1} = image1 = insert(:image, is_active: true, position: 1)
      %{filename: active_image_filename2} = image2 = insert(:image, is_active: true, position: 2)
      %{filename: active_image_filename3} = image3 = insert(:image, is_active: true, position: 3)

      %{filename: inactive_image_filename1} =
        image4 = insert(:image, is_active: false, position: 4)

      %{filename: inactive_image_filename2} =
        image5 = insert(:image, is_active: false, position: 5)

      %{street: street, street_number: street_number} = address = insert(:address)

      district = district_from_address(address)

      user = insert(:user)
      development = insert(:development)
      interests = insert_list(3, :interest)
      in_person_visits = insert_list(3, :in_person_visit)
      listings_favorites = insert_list(3, :listings_favorites)
      tour_visualisations = insert_list(3, :tour_visualisation)
      listings_visualisations = insert_list(3, :listing_visualisation)
      [unit1, unit2] = insert_list(2, :unit)

      [%{price: price1}, %{price: price2}, %{price: price3}] =
        price_history = insert_list(3, :price_history)

      %{id: listing_id, uuid: listing_uuid} =
        insert(
          :listing,
          address: address,
          images: [image1, image2, image3, image4, image5],
          user: user,
          development: development,
          interests: interests,
          in_person_visits: in_person_visits,
          listings_favorites: listings_favorites,
          tour_visualisations: tour_visualisations,
          listings_visualisations: listings_visualisations,
          price_history: price_history,
          units: [unit1, unit2],
          rooms: 2,
          area: 80,
          garage_spots: 1,
          bathrooms: 1,
          inserted_at: ~N[2018-01-01 10:00:00],
          suggested_price: 1000.00
        )

      %{id: related_id1} = insert(:listing, address: address, score: 4)
      %{id: related_id2} = insert(:listing, address: address, score: 3)

      variables = %{
        "id" => listing_id,
        "activeImagesIsActive" => true,
        "inactiveImagesIsActive" => false,
        "pagination" => %{
          "pageSize" => 2
        },
        "filters" => %{}
      }

      query = """
        query Listing (
          $id: ID!,
          $activeImagesIsActive: Boolean,
          $inactiveImagesIsActive: Boolean,
          $pagination: ListingPagination,
          $filters: ListingFilterInput
          ) {
          listing (id: $id) {
            uuid
            address {
              street
              streetNumber
              neighborhoodDescription
            }
            activeImages: images (isActive: $activeImagesIsActive) {
              filename
            }
            inactiveImages: images (isActive: $inactiveImagesIsActive) {
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
            previousPrices {
              price
            }
            suggestedPrice
            related (pagination: $pagination, filters: $filters) {
              listings {
                id
              }
            }
            development {
              uuid
            }
            units {
              uuid
            }
            insertedAt
          }
        }
      """

      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\":26279.0,\"listing_price\":26279.915}"
         }}
      )

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "uuid" => listing_uuid,
               "address" => %{
                 "street" => street,
                 "streetNumber" => street_number,
                 "neighborhoodDescription" => district.description
               },
               "activeImages" => [
                 %{"filename" => to_string(active_image_filename1)},
                 %{"filename" => to_string(active_image_filename2)},
                 %{"filename" => to_string(active_image_filename3)}
               ],
               "inactiveImages" => [
                 %{"filename" => to_string(inactive_image_filename1)},
                 %{"filename" => to_string(inactive_image_filename2)}
               ],
               "owner" => %{"name" => user.name},
               "interestCount" => 3,
               "inPersonVisitCount" => 3,
               "listingFavoriteCount" => 3,
               "tourVisualisationCount" => 3,
               "listingVisualisationCount" => 3,
               "previousPrices" => [
                 %{"price" => price1},
                 %{"price" => price2},
                 %{"price" => price3}
               ],
               "suggestedPrice" => 1000.0,
               "related" => %{
                 "listings" => [
                   %{"id" => to_string(related_id1)},
                   %{"id" => to_string(related_id2)}
                 ]
               },
               "development" => %{
                 "uuid" => development.uuid
               },
               "units" => [
                 %{"uuid" => to_string(unit1.uuid)},
                 %{"uuid" => to_string(unit2.uuid)}
               ],
               "insertedAt" => "2018-01-01T10:00:00"
             } == json_response(conn, 200)["data"]["listing"]
    end

    test "owner should query listing show", %{user_conn: conn, user_user: user} do
      %{filename: active_image_filename1} = image1 = insert(:image, is_active: true, position: 1)
      %{filename: active_image_filename2} = image2 = insert(:image, is_active: true, position: 2)
      %{filename: active_image_filename3} = image3 = insert(:image, is_active: true, position: 3)

      %{filename: inactive_image_filename1} =
        image4 = insert(:image, is_active: false, position: 4)

      %{filename: inactive_image_filename2} =
        image5 = insert(:image, is_active: false, position: 5)

      %{street: street, street_number: street_number} = address = insert(:address)

      district = district_from_address(address)

      interests = insert_list(3, :interest)
      in_person_visits = insert_list(3, :in_person_visit)
      listings_favorites = insert_list(3, :listings_favorites)
      tour_visualisations = insert_list(3, :tour_visualisation)
      listings_visualisations = insert_list(3, :listing_visualisation)
      [unit1, unit2] = insert_list(2, :unit)

      [%{price: price1}, %{price: price2}, %{price: price3}] =
        price_history = insert_list(3, :price_history)

      %{id: listing_id} =
        insert(
          :listing,
          address: address,
          images: [image1, image2, image3, image4, image5],
          user: user,
          interests: interests,
          in_person_visits: in_person_visits,
          listings_favorites: listings_favorites,
          tour_visualisations: tour_visualisations,
          listings_visualisations: listings_visualisations,
          price_history: price_history,
          units: [unit1, unit2],
          rooms: 2,
          area: 80,
          garage_spots: 1,
          bathrooms: 1,
          inserted_at: ~N[2018-01-01 10:00:00],
          suggested_price: nil
        )

      %{id: related_id1} = insert(:listing, address: address, score: 4)
      %{id: related_id2} = insert(:listing, address: address, score: 3)

      variables = %{
        "id" => listing_id,
        "activeImagesIsActive" => true,
        "inactiveImagesIsActive" => false,
        "pagination" => %{
          "pageSize" => 2
        },
        "filters" => %{}
      }

      query = """
        query Listing (
          $id: ID!,
          $activeImagesIsActive: Boolean,
          $inactiveImagesIsActive: Boolean,
          $pagination: ListingPagination,
          $filters: ListingFilterInput
          ) {
          listing (id: $id) {
            uuid
            address {
              street
              streetNumber
              neighborhoodDescription
            }
            activeImages: images (isActive: $activeImagesIsActive) {
              filename
            }
            inactiveImages: images (isActive: $inactiveImagesIsActive) {
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
            previousPrices {
              price
            }
            suggestedPrice
            related (pagination: $pagination, filters: $filters) {
              listings {
                id
              }
            }
            units {
              uuid
            }
            insertedAt
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "uuid" => nil,
               "address" => %{
                 "street" => street,
                 "streetNumber" => street_number,
                 "neighborhoodDescription" => district.description
               },
               "activeImages" => [
                 %{"filename" => to_string(active_image_filename1)},
                 %{"filename" => to_string(active_image_filename2)},
                 %{"filename" => to_string(active_image_filename3)}
               ],
               "inactiveImages" => [
                 %{"filename" => to_string(inactive_image_filename1)},
                 %{"filename" => to_string(inactive_image_filename2)}
               ],
               "owner" => %{"name" => user.name},
               "interestCount" => 3,
               "inPersonVisitCount" => 3,
               "listingFavoriteCount" => 3,
               "tourVisualisationCount" => 3,
               "listingVisualisationCount" => 3,
               "previousPrices" => [
                 %{"price" => price1},
                 %{"price" => price2},
                 %{"price" => price3}
               ],
               "suggestedPrice" => nil,
               "related" => %{
                 "listings" => [
                   %{"id" => to_string(related_id1)},
                   %{"id" => to_string(related_id2)}
                 ]
               },
               "units" => [
                 %{"uuid" => to_string(unit1.uuid)},
                 %{"uuid" => to_string(unit2.uuid)}
               ],
               "insertedAt" => "2018-01-01T10:00:00"
             } == json_response(conn, 200)["data"]["listing"]
    end

    test "user should query listing show", %{user_conn: conn} do
      %{filename: active_image_filename1} = image1 = insert(:image, is_active: true, position: 1)
      %{filename: active_image_filename2} = image2 = insert(:image, is_active: true, position: 2)
      %{filename: active_image_filename3} = image3 = insert(:image, is_active: true, position: 3)
      image4 = insert(:image, is_active: false, position: 4)
      image5 = insert(:image, is_active: false, position: 5)
      %{street: street} = address = insert(:address)

      district = district_from_address(address)

      user = insert(:user)
      [unit1, unit2] = insert_list(2, :unit)

      %{id: listing_id} =
        insert(:listing,
          address: address,
          images: [image1, image2, image3, image4, image5],
          units: [unit1, unit2],
          user: user,
          inserted_at: ~N[2018-01-01 10:00:00]
        )

      %{id: related_id1} = insert(:listing, address: address, score: 4)
      %{id: related_id2} = insert(:listing, address: address, score: 3)

      variables = %{
        "id" => listing_id,
        "activeImagesIsActive" => true,
        "inactiveImagesIsActive" => false,
        "pagination" => %{
          "pageSize" => 2
        },
        "filters" => %{}
      }

      query = """
        query Listing (
          $id: ID!,
          $activeImagesIsActive: Boolean,
          $inactiveImagesIsActive: Boolean,
          $pagination: ListingPagination,
          $filters: ListingFilterInput
          ) {
          listing (id: $id) {
            uuid
            address {
              street
              streetNumber
              neighborhoodDescription
            }
            activeImages: images (isActive: $activeImagesIsActive) {
              filename
            }
            inactiveImages: images (isActive: $inactiveImagesIsActive) {
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
            previousPrices {
              price
            }
            suggestedPrice
            related (pagination: $pagination, filters: $filters) {
              listings {
                id
              }
            }
            units {
              uuid
            }
            insertedAt
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "uuid" => nil,
               "address" => %{
                 "street" => street,
                 "streetNumber" => nil,
                 "neighborhoodDescription" => district.description
               },
               "activeImages" => [
                 %{"filename" => to_string(active_image_filename1)},
                 %{"filename" => to_string(active_image_filename2)},
                 %{"filename" => to_string(active_image_filename3)}
               ],
               "inactiveImages" => [
                 %{"filename" => to_string(active_image_filename1)},
                 %{"filename" => to_string(active_image_filename2)},
                 %{"filename" => to_string(active_image_filename3)}
               ],
               "owner" => nil,
               "interestCount" => nil,
               "inPersonVisitCount" => nil,
               "listingFavoriteCount" => nil,
               "tourVisualisationCount" => nil,
               "listingVisualisationCount" => nil,
               "previousPrices" => nil,
               "suggestedPrice" => nil,
               "related" => %{
                 "listings" => [
                   %{"id" => to_string(related_id1)},
                   %{"id" => to_string(related_id2)}
                 ]
               },
               "units" => [
                 %{"uuid" => to_string(unit1.uuid)},
                 %{"uuid" => to_string(unit2.uuid)}
               ],
               "insertedAt" => "2018-01-01T10:00:00"
             } == json_response(conn, 200)["data"]["listing"]
    end

    test "anonymous should query listing show", %{unauthenticated_conn: conn} do
      %{filename: active_image_filename1} = image1 = insert(:image, is_active: true, position: 1)
      %{filename: active_image_filename2} = image2 = insert(:image, is_active: true, position: 2)
      %{filename: active_image_filename3} = image3 = insert(:image, is_active: true, position: 3)
      image4 = insert(:image, is_active: false, position: 4)
      image5 = insert(:image, is_active: false, position: 5)
      %{street: street} = address = insert(:address)

      district = district_from_address(address)

      user = insert(:user)
      [unit1, unit2] = insert_list(2, :unit)

      %{id: listing_id} =
        insert(:listing,
          address: address,
          images: [image1, image2, image3, image4, image5],
          units: [unit1, unit2],
          user: user,
          inserted_at: ~N[2018-01-01 10:00:00]
        )

      %{id: related_id1} = insert(:listing, address: address, score: 4)
      %{id: related_id2} = insert(:listing, address: address, score: 3)

      variables = %{
        "id" => listing_id,
        "activeImagesIsActive" => true,
        "inactiveImagesIsActive" => false,
        "pagination" => %{
          "pageSize" => 2
        },
        "filters" => %{}
      }

      query = """
        query Listing (
          $id: ID!,
          $activeImagesIsActive: Boolean,
          $inactiveImagesIsActive: Boolean,
          $pagination: ListingPagination,
          $filters: ListingFilterInput
          ) {
          listing (id: $id) {
            uuid
            address {
              street
              streetNumber
              neighborhoodDescription
            }
            activeImages: images (isActive: $activeImagesIsActive) {
              filename
            }
            inactiveImages: images (isActive: $inactiveImagesIsActive) {
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
            previousPrices {
              price
            }
            suggestedPrice
            related (pagination: $pagination, filters: $filters) {
              listings {
                id
              }
            }
            units {
              uuid
            }
            insertedAt
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "uuid" => nil,
               "address" => %{
                 "street" => street,
                 "streetNumber" => nil,
                 "neighborhoodDescription" => district.description
               },
               "activeImages" => [
                 %{"filename" => to_string(active_image_filename1)},
                 %{"filename" => to_string(active_image_filename2)},
                 %{"filename" => to_string(active_image_filename3)}
               ],
               "inactiveImages" => [
                 %{"filename" => to_string(active_image_filename1)},
                 %{"filename" => to_string(active_image_filename2)},
                 %{"filename" => to_string(active_image_filename3)}
               ],
               "owner" => nil,
               "interestCount" => nil,
               "inPersonVisitCount" => nil,
               "listingFavoriteCount" => nil,
               "tourVisualisationCount" => nil,
               "listingVisualisationCount" => nil,
               "previousPrices" => nil,
               "suggestedPrice" => nil,
               "related" => %{
                 "listings" => [
                   %{"id" => to_string(related_id1)},
                   %{"id" => to_string(related_id2)}
                 ]
               },
               "units" => [
                 %{"uuid" => to_string(unit1.uuid)},
                 %{"uuid" => to_string(unit2.uuid)}
               ],
               "insertedAt" => "2018-01-01T10:00:00"
             } == json_response(conn, 200)["data"]["listing"]
    end

    test "admin should see inactive listing", %{admin_conn: conn} do
      %{id: listing_id} =
        insert(:listing,
          status: "inactive",
          inactivation_reason: "sold",
          sold_price: 1_000_000
        )

      variables = %{"id" => listing_id}

      query = """
        query Listing ($id: ID!) {
          listing (id: $id) {
            id
            inactivation_reason
            sold_price
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "id" => to_string(listing_id),
               "inactivation_reason" => "SOLD",
               "sold_price" => 1_000_000
             } == json_response(conn, 200)["data"]["listing"]
    end

    test "owner should see inactive listing", %{user_conn: conn, user_user: user} do
      %{id: listing_id} = insert(:listing, status: "inactive", user: user)

      variables = %{"id" => listing_id}

      query = """
        query Listing ($id: ID!) {
          listing (id: $id) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{"id" => to_string(listing_id)} == json_response(conn, 200)["data"]["listing"]
    end

    test "user should not see inactive listing", %{user_conn: conn} do
      %{id: listing_id} = insert(:listing, status: "inactive")

      variables = %{"id" => listing_id}

      query = """
        query Listing ($id: ID!) {
          listing (id: $id) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert [%{"message" => "Not found", "code" => 404}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not see inactive listing", %{unauthenticated_conn: conn} do
      %{id: listing_id} = insert(:listing, status: "inactive")

      variables = %{"id" => listing_id}

      query = """
        query Listing ($id: ID!) {
          listing (id: $id) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert [%{"message" => "Not found", "code" => 404}] = json_response(conn, 200)["errors"]
    end
  end

  describe "showFavoritedUsers" do
    test "admin should see favorited users", %{admin_conn: conn, admin_user: user} do
      listing = insert(:listing)
      insert(:listings_favorites, listing_id: listing.id, user_id: user.id)

      variables = %{"id" => listing.id}

      query = """
        query ShowFavoritedUsers ($id: ID!) {
          showFavoritedUsers(id: $id) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert [%{"id" => to_string(user.id)}] ==
               json_response(conn, 200)["data"]["showFavoritedUsers"]
    end

    test "admin should not see favorited users", %{user_conn: conn, user_user: user} do
      listing = insert(:listing)
      insert(:listings_favorites, listing_id: listing.id, user_id: user.id)

      variables = %{"id" => listing.id}

      query = """
        query ShowFavoritedUsers ($id: ID!) {
          showFavoritedUsers(id: $id) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not see favorited users", %{unauthenticated_conn: conn} do
      listing = insert(:listing)
      user = insert(:user)
      insert(:listings_favorites, listing_id: listing.id, user_id: user.id)

      variables = %{"id" => listing.id}

      query = """
        query ShowFavoritedUsers ($id: ID!) {
          showFavoritedUsers(id: $id) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end
  end

  describe "userListings" do
    test "admin should see its own listings users", %{admin_conn: conn, admin_user: user} do
      listing = insert(:listing, user: user)

      query = """
        query UserListings {
          userListings {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert [%{"id" => to_string(listing.id)}] ==
               json_response(conn, 200)["data"]["userListings"]
    end

    test "user should see its own listings users", %{user_conn: conn, user_user: user} do
      listing = insert(:listing, user: user)

      query = """
        query UserListings {
          userListings {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert [%{"id" => to_string(listing.id)}] ==
               json_response(conn, 200)["data"]["userListings"]
    end

    test "anonymous should not see own listings", %{unauthenticated_conn: conn} do
      query = """
        query UserListings {
          userListings {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end
  end
end
