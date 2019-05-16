defmodule ReWeb.ListingControllerTest do
  use ReWeb.ConnCase

  alias Re.{
    Address,
    Listing
  }

  alias ReWeb.Guardian

  import Re.Factory

  @valid_attrs_user %{
    type: "Casa",
    floor: "H1",
    complement: "basement",
    bathrooms: 2,
    restrooms: 2,
    description: "some content",
    price: 1_000_000,
    property_tax: 500.00,
    maintenance_fee: 300.00,
    rooms: 4,
    area: 140,
    garage_spots: 3,
    garage_type: "contract",
    suites: 1,
    dependencies: 1,
    balconies: 1,
    has_elevator: true,
    is_exclusive: true,
    is_release: true
  }
  @valid_attrs_admin %{
    type: "Casa",
    score: 3,
    floor: "H1",
    complement: "basement",
    bathrooms: 2,
    restrooms: 2,
    description: "some content",
    price: 1_000_000,
    property_tax: 500.00,
    maintenance_fee: 300.00,
    rooms: 4,
    area: 140,
    garage_spots: 3,
    garage_type: "contract",
    suites: 1,
    dependencies: 1,
    balconies: 1,
    has_elevator: true,
    is_exclusive: true,
    is_release: true
  }
  @valid_address_attrs %{
    street: "A Street",
    street_number: "100",
    neighborhood: "A Neighborhood",
    city: "A City",
    state: "ST",
    postal_code: "12345-678",
    lat: "25",
    lng: "25"
  }
  @invalid_attrs %{
    score: 7,
    bathrooms: -1,
    restrooms: -1,
    price: -1,
    property_tax: -500.00,
    maintenance_fee: -300.00,
    rooms: -1,
    area: -1,
    garage_spots: -1,
    garage_type: "mine",
    suites: -1,
    dependencies: -1,
    balconies: -1
  }

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

  describe "show" do
    test "resource for admin user", %{admin_conn: conn, admin_user: user} do
      image = insert(:image)
      listing = insert(:listing, images: [image], address: build(:address), user: user)
      insert_list(3, :listing_visualisation, listing_id: listing.id)
      insert_list(3, :tour_visualisation, listing_id: listing.id)
      insert(:listings_favorites, listing_id: listing.id, user_id: user.id)
      insert_list(2, :interest, listing_id: listing.id, interest_type: build(:interest_type))
      insert(:interest, listing_id: listing.id)
      insert_list(2, :in_person_visit, listing_id: listing.id, date: ~N[2018-05-05 10:00:00])
      conn = get(conn, listing_path(conn, :show, listing))

      assert json_response(conn, 200)["listing"] ==
               %{
                 "id" => listing.id,
                 "type" => listing.type,
                 "complement" => listing.complement,
                 "description" => listing.description,
                 "price" => listing.price,
                 "property_tax" => listing.property_tax,
                 "maintenance_fee" => listing.maintenance_fee,
                 "floor" => listing.floor,
                 "rooms" => listing.rooms,
                 "bathrooms" => listing.bathrooms,
                 "restrooms" => listing.restrooms,
                 "area" => listing.area,
                 "garage_spots" => listing.garage_spots,
                 "garage_type" => listing.garage_type,
                 "matterport_code" => listing.matterport_code,
                 "suites" => listing.suites,
                 "dependencies" => listing.dependencies,
                 "balconies" => listing.balconies,
                 "has_elevator" => listing.has_elevator,
                 "is_exclusive" => listing.is_exclusive,
                 "is_release" => listing.is_release,
                 "is_active" => listing.status == "active",
                 "inserted_at" => NaiveDateTime.to_iso8601(listing.inserted_at),
                 "user_id" => listing.user_id,
                 "images" => [
                   %{
                     "id" => image.id,
                     "filename" => image.filename,
                     "position" => image.position,
                     "description" => image.description
                   }
                 ],
                 "address" => %{
                   "street" => listing.address.street,
                   "street_slug" => listing.address.street_slug,
                   "street_number" => listing.address.street_number,
                   "neighborhood" => listing.address.neighborhood,
                   "neighborhood_slug" => listing.address.neighborhood_slug,
                   "city" => listing.address.city,
                   "city_slug" => listing.address.city_slug,
                   "state" => listing.address.state,
                   "state_slug" => listing.address.state_slug,
                   "postal_code" => listing.address.postal_code,
                   "lat" => listing.address.lat,
                   "lng" => listing.address.lng
                 },
                 "visualisations" => 3,
                 "in_person_visit_count" => 2,
                 "tour_visualisations" => 3,
                 "favorite_count" => 1,
                 "interest_count" => 2
               }
    end

    test "resource for admin when listing doesn't belong to him", %{
      admin_conn: conn,
      user_user: user
    } do
      image = insert(:image)
      listing = insert(:listing, images: [image], address: build(:address), user: user)
      insert_list(3, :listing_visualisation, listing_id: listing.id)
      insert_list(3, :tour_visualisation, listing_id: listing.id)
      insert(:listings_favorites, listing_id: listing.id, user_id: user.id)
      insert_list(2, :interest, listing_id: listing.id, interest_type: build(:interest_type))
      insert(:interest, listing_id: listing.id)
      insert_list(3, :in_person_visit, listing_id: listing.id, date: ~N[2018-05-05 10:00:00])
      conn = get(conn, listing_path(conn, :show, listing))

      assert json_response(conn, 200)["listing"] ==
               %{
                 "id" => listing.id,
                 "type" => listing.type,
                 "complement" => listing.complement,
                 "description" => listing.description,
                 "price" => listing.price,
                 "property_tax" => listing.property_tax,
                 "maintenance_fee" => listing.maintenance_fee,
                 "floor" => listing.floor,
                 "rooms" => listing.rooms,
                 "bathrooms" => listing.bathrooms,
                 "restrooms" => listing.restrooms,
                 "area" => listing.area,
                 "garage_spots" => listing.garage_spots,
                 "garage_type" => listing.garage_type,
                 "matterport_code" => listing.matterport_code,
                 "suites" => listing.suites,
                 "dependencies" => listing.dependencies,
                 "balconies" => listing.balconies,
                 "has_elevator" => listing.has_elevator,
                 "is_exclusive" => listing.is_exclusive,
                 "is_release" => listing.is_release,
                 "is_active" => listing.status == "active",
                 "inserted_at" => NaiveDateTime.to_iso8601(listing.inserted_at),
                 "user_id" => listing.user_id,
                 "images" => [
                   %{
                     "id" => image.id,
                     "filename" => image.filename,
                     "position" => image.position,
                     "description" => image.description
                   }
                 ],
                 "address" => %{
                   "street" => listing.address.street,
                   "street_slug" => listing.address.street_slug,
                   "street_number" => listing.address.street_number,
                   "neighborhood" => listing.address.neighborhood,
                   "neighborhood_slug" => listing.address.neighborhood_slug,
                   "city" => listing.address.city,
                   "city_slug" => listing.address.city_slug,
                   "state" => listing.address.state,
                   "state_slug" => listing.address.state_slug,
                   "postal_code" => listing.address.postal_code,
                   "lat" => listing.address.lat,
                   "lng" => listing.address.lng
                 },
                 "visualisations" => 3,
                 "in_person_visit_count" => 3,
                 "tour_visualisations" => 3,
                 "favorite_count" => 1,
                 "interest_count" => 2
               }
    end

    test "resource for owner user", %{user_conn: conn, user_user: user} do
      image = insert(:image)
      listing = insert(:listing, images: [image], address: build(:address), user: user)
      insert_list(3, :listing_visualisation, listing_id: listing.id)
      insert_list(3, :tour_visualisation, listing_id: listing.id)
      insert(:listings_favorites, listing_id: listing.id, user_id: user.id)
      insert_list(2, :interest, listing_id: listing.id, interest_type: build(:interest_type))
      insert(:interest, listing_id: listing.id)
      insert_list(2, :in_person_visit, listing_id: listing.id, date: ~N[2018-05-05 10:00:00])
      conn = get(conn, listing_path(conn, :show, listing))

      assert json_response(conn, 200)["listing"] ==
               %{
                 "id" => listing.id,
                 "type" => listing.type,
                 "complement" => listing.complement,
                 "description" => listing.description,
                 "price" => listing.price,
                 "property_tax" => listing.property_tax,
                 "maintenance_fee" => listing.maintenance_fee,
                 "floor" => listing.floor,
                 "rooms" => listing.rooms,
                 "bathrooms" => listing.bathrooms,
                 "restrooms" => listing.restrooms,
                 "area" => listing.area,
                 "garage_spots" => listing.garage_spots,
                 "garage_type" => listing.garage_type,
                 "matterport_code" => listing.matterport_code,
                 "suites" => listing.suites,
                 "dependencies" => listing.dependencies,
                 "balconies" => listing.balconies,
                 "has_elevator" => listing.has_elevator,
                 "is_exclusive" => listing.is_exclusive,
                 "is_release" => listing.is_release,
                 "is_active" => listing.status == "active",
                 "inserted_at" => NaiveDateTime.to_iso8601(listing.inserted_at),
                 "user_id" => listing.user_id,
                 "images" => [
                   %{
                     "id" => image.id,
                     "filename" => image.filename,
                     "position" => image.position,
                     "description" => image.description
                   }
                 ],
                 "address" => %{
                   "street" => listing.address.street,
                   "street_slug" => listing.address.street_slug,
                   "street_number" => listing.address.street_number,
                   "neighborhood" => listing.address.neighborhood,
                   "neighborhood_slug" => listing.address.neighborhood_slug,
                   "city" => listing.address.city,
                   "city_slug" => listing.address.city_slug,
                   "state" => listing.address.state,
                   "state_slug" => listing.address.state_slug,
                   "postal_code" => listing.address.postal_code,
                   "lat" => listing.address.lat,
                   "lng" => listing.address.lng
                 },
                 "visualisations" => 3,
                 "in_person_visit_count" => 2,
                 "tour_visualisations" => 3,
                 "favorite_count" => 1,
                 "interest_count" => 2
               }
    end

    test "resource for non user", %{user_conn: conn, admin_user: user} do
      address = insert(:address)
      image = insert(:image)
      listing = insert(:listing, images: [image], address: address, user: user)
      insert_list(3, :listing_visualisation, listing_id: listing.id)
      insert_list(3, :tour_visualisation, listing_id: listing.id)
      insert(:listings_favorites, listing_id: listing.id, user_id: user.id)
      insert_list(2, :interest, listing_id: listing.id, interest_type: build(:interest_type))
      insert(:interest, listing_id: listing.id)
      conn = get(conn, listing_path(conn, :show, listing))

      assert json_response(conn, 200)["listing"] ==
               %{
                 "id" => listing.id,
                 "type" => listing.type,
                 "description" => listing.description,
                 "price" => listing.price,
                 "property_tax" => listing.property_tax,
                 "maintenance_fee" => listing.maintenance_fee,
                 "floor" => listing.floor,
                 "rooms" => listing.rooms,
                 "bathrooms" => listing.bathrooms,
                 "restrooms" => listing.restrooms,
                 "area" => listing.area,
                 "garage_spots" => listing.garage_spots,
                 "garage_type" => listing.garage_type,
                 "matterport_code" => listing.matterport_code,
                 "suites" => listing.suites,
                 "dependencies" => listing.dependencies,
                 "balconies" => listing.balconies,
                 "has_elevator" => listing.has_elevator,
                 "is_exclusive" => listing.is_exclusive,
                 "is_release" => listing.is_release,
                 "is_active" => listing.status == "active",
                 "inserted_at" => NaiveDateTime.to_iso8601(listing.inserted_at),
                 "user_id" => listing.user_id,
                 "images" => [
                   %{
                     "id" => image.id,
                     "filename" => image.filename,
                     "position" => image.position,
                     "description" => image.description
                   }
                 ],
                 "address" => %{
                   "street" => listing.address.street,
                   "street_slug" => listing.address.street_slug,
                   "neighborhood" => listing.address.neighborhood,
                   "neighborhood_slug" => listing.address.neighborhood_slug,
                   "city" => listing.address.city,
                   "city_slug" => listing.address.city_slug,
                   "state" => listing.address.state,
                   "state_slug" => listing.address.state_slug,
                   "postal_code" => listing.address.postal_code,
                   "lat" => listing.address.lat,
                   "lng" => listing.address.lng
                 }
               }
    end

    test "do not show inactive listing for non admin user", %{user_conn: conn} do
      image = insert(:image)

      listing = insert(:listing, images: [image], address: build(:address), status: "inactive")

      conn = get(conn, listing_path(conn, :show, listing))
      json_response(conn, 404)
    end

    test "do not show inactive listing for unauthenticated user", %{unauthenticated_conn: conn} do
      image = insert(:image)

      listing = insert(:listing, images: [image], address: build(:address), status: "inactive")

      conn = get(conn, listing_path(conn, :show, listing))
      json_response(conn, 404)
    end

    test "show inactive listing for admin user", %{admin_conn: conn} do
      image = insert(:image)

      listing = insert(:listing, images: [image], address: build(:address), status: "inactive")

      conn = get(conn, listing_path(conn, :show, listing))
      json_response(conn, 200)
    end

    test "show inactive listing for owner user", %{user_conn: conn, user_user: user} do
      image = insert(:image)

      listing =
        insert(
          :listing,
          images: [image],
          address: build(:address),
          status: "inactive",
          user_id: user.id
        )

      conn = get(conn, listing_path(conn, :show, listing))
      json_response(conn, 200)
    end

    test "renders page not found when id is nonexistent", %{admin_conn: conn} do
      conn = get(conn, listing_path(conn, :show, -1))
      json_response(conn, 404)
    end

    test "list listing for unauthenticated requests even if not authenticated", %{
      unauthenticated_conn: conn,
      admin_user: user
    } do
      image = insert(:image)
      listing = insert(:listing, images: [image], address: build(:address), user: user)

      conn = get(conn, listing_path(conn, :show, listing))
      json_response(conn, 200)
    end

    test "do not show inactive image", %{
      unauthenticated_conn: conn,
      admin_user: user
    } do
      %{id: id1} = image1 = insert(:image, position: 1)
      %{id: id2} = image2 = insert(:image, position: 2)
      image3 = insert(:image, is_active: false)

      listing =
        insert(:listing, images: [image1, image2, image3], address: build(:address), user: user)

      conn = get(conn, listing_path(conn, :show, listing))
      response = json_response(conn, 200)
      assert [%{"id" => ^id1}, %{"id" => ^id2}] = response["listing"]["images"]
    end
  end

  describe "edit" do
    test "edits chosen resource", %{admin_conn: conn, admin_user: user} do
      image = insert(:image)
      listing = insert(:listing, images: [image], address: build(:address), user: user)
      conn = get(conn, listing_path(conn, :edit, listing))

      assert json_response(conn, 200)["listing"] ==
               %{
                 "id" => listing.id,
                 "type" => listing.type,
                 "complement" => listing.complement,
                 "description" => listing.description,
                 "price" => listing.price,
                 "property_tax" => listing.property_tax,
                 "maintenance_fee" => listing.maintenance_fee,
                 "floor" => listing.floor,
                 "rooms" => listing.rooms,
                 "bathrooms" => listing.bathrooms,
                 "restrooms" => listing.restrooms,
                 "area" => listing.area,
                 "garage_spots" => listing.garage_spots,
                 "garage_type" => listing.garage_type,
                 "score" => listing.score,
                 "matterport_code" => listing.matterport_code,
                 "suites" => listing.suites,
                 "dependencies" => listing.dependencies,
                 "balconies" => listing.balconies,
                 "has_elevator" => listing.has_elevator,
                 "is_exclusive" => listing.is_exclusive,
                 "is_release" => listing.is_release,
                 "is_active" => listing.status == "active",
                 "inserted_at" => NaiveDateTime.to_iso8601(listing.inserted_at),
                 "images" => [
                   %{
                     "id" => image.id,
                     "filename" => image.filename,
                     "position" => image.position,
                     "description" => image.description
                   }
                 ],
                 "address" => %{
                   "street" => listing.address.street,
                   "street_slug" => listing.address.street_slug,
                   "street_number" => listing.address.street_number,
                   "neighborhood" => listing.address.neighborhood,
                   "neighborhood_slug" => listing.address.neighborhood_slug,
                   "city" => listing.address.city,
                   "city_slug" => listing.address.city_slug,
                   "state" => listing.address.state,
                   "state_slug" => listing.address.state_slug,
                   "postal_code" => listing.address.postal_code,
                   "lat" => listing.address.lat,
                   "lng" => listing.address.lng
                 }
               }
    end

    test "do not edit if listing as user", %{user_conn: conn, user_user: user} do
      image = insert(:image)
      listing = insert(:listing, images: [image], address: build(:address), user: user)
      conn = get(conn, listing_path(conn, :edit, listing))
      assert json_response(conn, 403)
    end

    test "fails if listing does not belong to user", %{user_conn: conn, admin_user: user} do
      image = insert(:image)
      listing = insert(:listing, images: [image], address: build(:address), user: user)
      conn = get(conn, listing_path(conn, :edit, listing))
      assert json_response(conn, 403)
    end

    test "renders page not found when id is nonexistent", %{admin_conn: conn} do
      conn = get(conn, listing_path(conn, :edit, -1))
      json_response(conn, 404)
    end

    test "does not list listing for unauthenticated requests even if not authenticated", %{
      unauthenticated_conn: conn,
      admin_user: user
    } do
      image = insert(:image)
      listing = insert(:listing, images: [image], address: build(:address), user: user)

      conn = get(conn, listing_path(conn, :edit, listing))
      json_response(conn, 401)
    end
  end

  describe "create" do
    test "creates and renders resource as admin", %{admin_conn: conn, admin_user: user} do
      conn =
        post(
          conn,
          listing_path(conn, :create),
          listing: @valid_attrs_admin,
          address: @valid_address_attrs
        )

      response = json_response(conn, 201)
      assert response["listing"]["id"]
      assert listing = Repo.get_by(Listing, @valid_attrs_admin)
      assert listing.user_id == user.id
    end

    test "do not creates and renders resource as user", %{user_conn: conn} do
      conn =
        post(conn, listing_path(conn, :create), %{
          listing: @valid_attrs_user,
          address: @valid_address_attrs
        })

      json_response(conn, 403)
      refute Repo.one(Listing)
    end

    test "creates and renders resource with existing address", %{admin_conn: conn} do
      insert(:address, @valid_address_attrs)

      conn =
        post(
          conn,
          listing_path(conn, :create),
          listing: @valid_attrs_admin,
          address: @valid_address_attrs
        )

      response = json_response(conn, 201)
      assert response["listing"]["id"]
      assert Repo.get_by(Listing, @valid_attrs_admin)
      assert length(Repo.all(Address)) == 1
    end

    test "does not create resource and renders errors when data is invalid", %{admin_conn: conn} do
      conn =
        post(conn, listing_path(conn, :create), %{
          listing: @invalid_attrs,
          address: @valid_address_attrs
        })

      assert json_response(conn, 422)["errors"] != %{}
      assert Repo.all(Listing) == []
    end

    test "does not create resource when user is not authenticated", %{unauthenticated_conn: conn} do
      conn =
        post(conn, listing_path(conn, :create), %{
          listing: @valid_attrs_user,
          address: @valid_address_attrs
        })

      json_response(conn, 401)
      refute Repo.get_by(Listing, @valid_attrs_user)
    end
  end

  describe "update" do
    test "updates and renders chosen resource when data is valid", %{
      admin_conn: conn,
      admin_user: user
    } do
      listing = insert(:listing, address: build(:address), user: user)

      conn =
        put(
          conn,
          listing_path(conn, :update, listing),
          id: listing.id,
          listing: @valid_attrs_admin,
          address: @valid_address_attrs
        )

      assert json_response(conn, 200)["listing"]["id"]
      assert Repo.get_by(Listing, @valid_attrs_admin)
    end

    test "does not update chosen resource and renders errors when data is invalid", %{
      admin_conn: conn,
      admin_user: user
    } do
      listing = insert(:listing, address: build(:address), user: user)

      conn =
        put(conn, listing_path(conn, :update, listing), %{
          id: listing.id,
          listing: @invalid_attrs,
          address: @valid_address_attrs
        })

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "does not update resource when user is not authenticated", %{unauthenticated_conn: conn} do
      listing = insert(:listing, address: build(:address))

      conn =
        put(
          conn,
          listing_path(conn, :update, listing),
          id: listing.id,
          listing: @valid_attrs_user,
          address: @valid_address_attrs
        )

      assert json_response(conn, 401)
      refute Repo.get_by(Listing, @valid_attrs_user)
    end

    test "do not update resource when listing belongs to user", %{
      user_conn: conn,
      user_user: user
    } do
      listing = insert(:listing, address: build(:address), user: user)

      conn =
        put(
          conn,
          listing_path(conn, :update, listing),
          id: listing.id,
          listing: @valid_attrs_user,
          address: @valid_address_attrs
        )

      assert json_response(conn, 403)
    end

    test "does not update resource when listing doesn't belong to user", %{
      user_conn: conn,
      admin_user: user
    } do
      listing = insert(:listing, address: build(:address), user: user)

      conn =
        put(
          conn,
          listing_path(conn, :update, listing),
          id: listing.id,
          listing: @valid_attrs_admin,
          address: @valid_address_attrs
        )

      assert json_response(conn, 403)
      refute Repo.get_by(Listing, @valid_attrs_admin)
    end
  end

  describe "delete" do
    test "deletes chosen resource", %{admin_conn: conn} do
      listing = insert(:listing)
      conn = delete(conn, listing_path(conn, :delete, listing))
      assert response(conn, 204)
      assert listing = Repo.get(Listing, listing.id)
      assert listing.status == "inactive"
    end

    test "does not delete resource when user is not authenticated", %{unauthenticated_conn: conn} do
      listing = insert(:listing)
      conn = delete(conn, listing_path(conn, :delete, listing))
      assert response(conn, 401)
      assert listing = Repo.get(Listing, listing.id)
      assert listing.status == "active"
    end

    test "do not delete resource when listing belongs to user", %{
      user_conn: conn,
      user_user: user
    } do
      listing = insert(:listing, user: user)
      conn = delete(conn, listing_path(conn, :delete, listing))
      assert response(conn, 403)
      assert listing = Repo.get(Listing, listing.id)
      assert listing.status == "active"
    end

    test "doest not delete resource when listing doesn't belong to user", %{
      user_conn: conn,
      admin_user: user
    } do
      listing = insert(:listing, user: user)
      conn = delete(conn, listing_path(conn, :delete, listing))
      assert response(conn, 403)
      assert listing = Repo.get(Listing, listing.id)
      assert listing.status == "active"
    end
  end

  describe "coordinates" do
    test "admin gets all coordinates", %{admin_conn: conn} do
      %{id: id1} = insert(:listing, address: build(:address, lat: 10.0, lng: 10.0))
      %{id: id2} = insert(:listing, address: build(:address, lat: 20.0, lng: 20.0))

      conn = get(conn, listing_path(conn, :coordinates))

      assert response = json_response(conn, 200)

      assert [
               %{"id" => ^id1, "address" => %{"lat" => 10.0, "lng" => 10.0}},
               %{"id" => ^id2, "address" => %{"lat" => 20.0, "lng" => 20.0}}
             ] = response["listings"]
    end

    test "user gets all coordinates", %{user_conn: conn} do
      %{id: id1} = insert(:listing, address: build(:address, lat: 10.0, lng: 10.0))
      %{id: id2} = insert(:listing, address: build(:address, lat: 20.0, lng: 20.0))

      conn = get(conn, listing_path(conn, :coordinates))

      assert response = json_response(conn, 200)

      assert [
               %{"id" => ^id1, "address" => %{"lat" => 10.0, "lng" => 10.0}},
               %{"id" => ^id2, "address" => %{"lat" => 20.0, "lng" => 20.0}}
             ] = response["listings"]
    end

    test "anonymous gets all coordinates", %{unauthenticated_conn: conn} do
      %{id: id1} = insert(:listing, address: build(:address, lat: 10.0, lng: 10.0))
      %{id: id2} = insert(:listing, address: build(:address, lat: 20.0, lng: 20.0))

      conn = get(conn, listing_path(conn, :coordinates))

      assert response = json_response(conn, 200)

      assert [
               %{"id" => ^id1, "address" => %{"lat" => 10.0, "lng" => 10.0}},
               %{"id" => ^id2, "address" => %{"lat" => 20.0, "lng" => 20.0}}
             ] = response["listings"]
    end
  end
end
