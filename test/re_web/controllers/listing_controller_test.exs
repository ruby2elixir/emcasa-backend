defmodule ReWeb.ListingControllerTest do
  use ReWeb.ConnCase

  alias Re.{
    Address,
    Listing,
    Image
  }
  alias ReWeb.Guardian

  import Re.Factory

  @valid_attrs %{type: "apto", score: 3, floor: "H1", complement: "basement", bathrooms: 2, description: "some content", price: 1_000_000, rooms: 4, area: 140, garage_spots: 3,}
  @valid_address_attrs %{street: "A Street", street_number: "100", neighborhood: "A Neighborhood", city: "A City", state: "ST", postal_code: "12345-678", lat: "25", lng: "25"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    {:ok,
      unauthenticated_conn: conn,
      admin_conn: login_as(conn, insert(:user, email: "admin@email.com", role: "admin")),
      user_conn: login_as(conn, insert(:user, email: "user@email.com", role: "user"))
    }
  end

  describe "index" do
    test "admin user", %{admin_conn: conn} do
      address = insert(:address)
      listing = insert(:listing, address: address)

      conn = get conn, listing_path(conn, :index)

      listings = json_response(conn, 200)["listings"]
      retrieved_listing = List.first(listings)
      assert retrieved_listing["description"] == listing.description
    end

    test "not admin user", %{user_conn: conn} do
      address = insert(:address)
      listing = insert(:listing, address: address)

      conn = get conn, listing_path(conn, :index)

      listings = json_response(conn, 200)["listings"]
      retrieved_listing = List.first(listings)
      assert retrieved_listing["description"] == listing.description
    end

    test "filters by neighborhood", %{admin_conn: conn} do
      address = insert(:address)
      insert(:listing, address: address)

      address2 = insert(:address, postal_code: "12345", neighborhood: "Another neighborhood")
      listing2 = insert(:listing, address: address2, description: "Another description")
      conn = get conn, listing_path(conn, :index, neighborhood: address2.neighborhood)

      listings = json_response(conn, 200)["listings"]
      assert length(listings) == 1

      retrieved_listing = List.first(listings)
      assert retrieved_listing["description"] == listing2.description
    end

    test "paginated query", %{admin_conn: conn} do
      address = insert(:address)
      insert_list(5, :listing, address: address)

      conn = get conn, listing_path(conn, :index, %{page_size: 2, page: 1})

      assert [_, _] = json_response(conn, 200)["listings"]
      assert 1 == json_response(conn, 200)["page_number"]
      assert 2 == json_response(conn, 200)["page_size"]
      assert 3 == json_response(conn, 200)["total_pages"]
      assert 5 == json_response(conn, 200)["total_entries"]

      conn = get conn, listing_path(conn, :index, %{page_size: 2, page: 2})

      assert [_, _] = json_response(conn, 200)["listings"]
      assert 2 == json_response(conn, 200)["page_number"]
      assert 2 == json_response(conn, 200)["page_size"]
      assert 3 == json_response(conn, 200)["total_pages"]
      assert 5 == json_response(conn, 200)["total_entries"]
    end
  end

  describe "show" do
    test "resource for admin user", %{admin_conn: conn} do
      address = insert(:address)
      image = insert(:image)
      listing = insert(:listing, images: [image], address: address)
      conn = get conn, listing_path(conn, :show, listing)
      assert json_response(conn, 200)["listing"] ==
        %{
          "id" => listing.id,
          "type" => listing.type,
          "description" => listing.description,
          "price" => listing.price,
          "floor" => listing.floor,
          "rooms" => listing.rooms,
          "bathrooms" => listing.bathrooms,
          "area" => listing.area,
          "garage_spots" => listing.garage_spots,
          "matterport_code" => listing.matterport_code,
          "images" => [%{
            "id" => image.id,
            "filename" => image.filename,
            "position" => image.position
          }],
          "address" => %{
            "street" => listing.address.street,
            "street_number" => listing.address.street_number,
            "neighborhood" => listing.address.neighborhood,
            "city" => listing.address.city,
            "state" => listing.address.state,
            "postal_code" => listing.address.postal_code,
            "lat" => listing.address.lat,
            "lng" => listing.address.lng
          }
        }
    end

    test "resource for non user", %{user_conn: conn} do
      address = insert(:address)
      image = insert(:image)
      listing = insert(:listing, images: [image], address: address)
      conn = get conn, listing_path(conn, :show, listing)
      assert json_response(conn, 200)["listing"] ==
        %{
          "id" => listing.id,
          "type" => listing.type,
          "description" => listing.description,
          "price" => listing.price,
          "floor" => listing.floor,
          "rooms" => listing.rooms,
          "bathrooms" => listing.bathrooms,
          "area" => listing.area,
          "garage_spots" => listing.garage_spots,
          "matterport_code" => listing.matterport_code,
          "images" => [%{
            "id" => image.id,
            "filename" => image.filename,
            "position" => image.position
          }],
          "address" => %{
            "street" => listing.address.street,
            "street_number" => listing.address.street_number,
            "neighborhood" => listing.address.neighborhood,
            "city" => listing.address.city,
            "state" => listing.address.state,
            "postal_code" => listing.address.postal_code,
            "lat" => listing.address.lat,
            "lng" => listing.address.lng
          }
        }
    end

    test "do not show inactive listing", %{admin_conn: conn} do
      address = insert(:address)
      image = insert(:image)
      listing = insert(:listing, images: [image], address: address, is_active: false)
      conn = get conn, listing_path(conn, :show, listing)
      json_response(conn, 404)
    end

    test "renders page not found when id is nonexistent", %{admin_conn: conn} do
      conn = get conn, listing_path(conn, :show, -1)
      json_response(conn, 404)
    end

    test "list listing for unauthenticated requests even if not authenticated", %{unauthenticated_conn: conn} do
      address = insert(:address)
      image = insert(:image)
      listing = insert(:listing, images: [image], address: address)

      conn = get conn, listing_path(conn, :show, listing)
      json_response(conn, 200)
    end
  end

  describe "edit" do
    test "edits chosen resource", %{admin_conn: conn} do
      address = insert(:address)
      image = insert(:image)
      listing = insert(:listing, images: [image], address: address)
      conn = get conn, listing_path(conn, :edit, listing)
      assert json_response(conn, 200)["listing"] ==
        %{
          "id" => listing.id,
          "type" => listing.type,
          "complement" => listing.complement,
          "description" => listing.description,
          "price" => listing.price,
          "floor" => listing.floor,
          "rooms" => listing.rooms,
          "bathrooms" => listing.bathrooms,
          "area" => listing.area,
          "garage_spots" => listing.garage_spots,
          "score" => listing.score,
          "matterport_code" => listing.matterport_code,
          "images" => [%{
            "id" => image.id,
            "filename" => image.filename,
            "position" => image.position
          }],
          "address" => %{
            "street" => listing.address.street,
            "street_number" => listing.address.street_number,
            "neighborhood" => listing.address.neighborhood,
            "city" => listing.address.city,
            "state" => listing.address.state,
            "postal_code" => listing.address.postal_code,
            "lat" => listing.address.lat,
            "lng" => listing.address.lng
          }
        }
    end

    test "fails for non admin user", %{user_conn: conn} do
      address = insert(:address)
      image = insert(:image)
      listing = insert(:listing, images: [image], address: address)
      conn = get conn, listing_path(conn, :edit, listing)
      assert json_response(conn, 403)
    end

    test "renders page not found when id is nonexistent", %{admin_conn: conn} do
      conn = get conn, listing_path(conn, :edit, -1)
      json_response(conn, 404)
    end

    test "does not list listing for unauthenticated requests even if not authenticated", %{unauthenticated_conn: conn} do
      address = insert(:address)
      image = insert(:image)
      listing = insert(:listing, images: [image], address: address)

      conn = get conn, listing_path(conn, :edit, listing)
      json_response(conn, 401)
    end
  end

  describe "create" do
    test "creates and renders resource when data is valid", %{admin_conn: conn} do
      conn = post conn, listing_path(conn, :create), listing: @valid_attrs, address: @valid_address_attrs
      response = json_response(conn, 201)
      assert response["listing"]["id"]
      assert Repo.get_by(Listing, @valid_attrs)
    end

    test "creates and renders resource with existing address", %{admin_conn: conn} do
      insert(:address, @valid_address_attrs)
      conn = post conn, listing_path(conn, :create), listing: @valid_attrs, address: @valid_address_attrs
      response = json_response(conn, 201)
      assert response["listing"]["id"]
      assert Repo.get_by(Listing, @valid_attrs)
      assert length(Repo.all(Address)) == 1
    end

    test "does not create resource and renders errors when data is invalid", %{admin_conn: conn} do
      conn = post(conn, listing_path(conn, :create), %{listing: @invalid_attrs, address: @valid_address_attrs})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "does not create resource when user is not authenticated", %{unauthenticated_conn: conn} do
      conn = post(conn, listing_path(conn, :create), %{listing: @valid_attrs, address: @valid_address_attrs})
      json_response(conn, 401)
      refute Repo.get_by(Listing, @valid_attrs)
    end

    test "does not create resource when user is not admin", %{user_conn: conn} do
      conn = post(conn, listing_path(conn, :create), %{listing: @valid_attrs, address: @valid_address_attrs})
      json_response(conn, 403)
      refute Repo.get_by(Listing, @valid_attrs)
    end
  end

  describe "update" do
    test "updates and renders chosen resource when data is valid", %{admin_conn: conn} do
      listing = insert(:listing, address: build(:address))
      conn = put conn, listing_path(conn, :update, listing),
        id: listing.id, listing: @valid_attrs, address: @valid_address_attrs
      assert json_response(conn, 200)["listing"]["id"]
      assert Repo.get_by(Listing, @valid_attrs)
    end

    test "does not update chosen resource and renders errors when data is invalid", %{admin_conn: conn} do
      address = Repo.insert! %Re.Address{}
      listing = Repo.insert! %Listing{address_id: address.id}

      conn = put(conn, listing_path(conn, :update, listing), %{id: listing.id, listing: @invalid_attrs, address: @valid_address_attrs})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "does not update resource when user is not authenticated", %{unauthenticated_conn: conn} do
      listing = insert(:listing, address: build(:address))
      conn = put conn, listing_path(conn, :update, listing),
        id: listing.id, listing: @valid_attrs, address: @valid_address_attrs
      assert json_response(conn, 401)
      refute Repo.get_by(Listing, @valid_attrs)
    end

    test "does not update resource when user is not admin", %{user_conn: conn} do
      listing = insert(:listing, address: build(:address))
      conn = put conn, listing_path(conn, :update, listing),
        id: listing.id, listing: @valid_attrs, address: @valid_address_attrs
      assert json_response(conn, 403)
      refute Repo.get_by(Listing, @valid_attrs)
    end
  end

  describe "delete" do
    test "deletes chosen resource", %{admin_conn: conn} do
      listing = insert(:listing)
      conn = delete conn, listing_path(conn, :delete, listing)
      assert response(conn, 204)
      assert listing = Repo.get(Listing, listing.id)
      refute listing.is_active
    end

    test "does not delete resource when user is not authenticated", %{unauthenticated_conn: conn} do
      listing = insert(:listing)
      conn = delete conn, listing_path(conn, :delete, listing)
      assert response(conn, 401)
      assert listing = Repo.get(Listing, listing.id)
      assert listing.is_active
    end

    test "does not delete resource when user is not admin", %{user_conn: conn} do
      listing = insert(:listing)
      conn = delete conn, listing_path(conn, :delete, listing)
      assert response(conn, 403)
      assert listing = Repo.get(Listing, listing.id)
      assert listing.is_active
    end
  end

  describe "order" do
    test "update images order on listing by position", %{admin_conn: conn} do
      listing = insert(:listing)
      [%{id: id1}, %{id: id2}, %{id: id3}] = insert_list(3, :image, listing_id: listing.id)
      image_params = [
        %{id: id1, position: 2},
        %{id: id2, position: 3},
        %{id: id3, position: 1}
      ]
      # conn = patch conn, listing_listing_path(conn, :order, images: image_params)
      conn = dispatch(conn, @endpoint, "put", "/listings/#{listing.id}/image_order", images: image_params)
      assert response(conn, 204)
      im1 = Repo.get(Image, id1)
      im2 = Repo.get(Image, id2)
      im3 = Repo.get(Image, id3)
      assert im1.position == 2
      assert im2.position == 3
      assert im3.position == 1
    end

    test "does not update images order when unauthenticated", %{unauthenticated_conn: conn} do
      listing = insert(:listing)
      [%{id: id1}, %{id: id2}, %{id: id3}] = insert_list(3, :image, listing_id: listing.id)
      image_params = [
        %{id: id1, position: 2},
        %{id: id2, position: 3},
        %{id: id3, position: 1}
      ]
      # conn = patch conn, listing_listing_path(conn, :order, images: image_params)
      conn = dispatch(conn, @endpoint, "put", "/listings/#{listing.id}/image_order", images: image_params)
      assert json_response(conn, 401)
    end

    test "does not update images order when not admin", %{user_conn: conn} do
      listing = insert(:listing)
      [%{id: id1}, %{id: id2}, %{id: id3}] = insert_list(3, :image, listing_id: listing.id)
      image_params = [
        %{id: id1, position: 2},
        %{id: id2, position: 3},
        %{id: id3, position: 1}
      ]
      # conn = patch conn, listing_listing_path(conn, :order, images: image_params)
      conn = dispatch(conn, @endpoint, "put", "/listings/#{listing.id}/image_order", images: image_params)
      assert json_response(conn, 403)
    end
  end
end
