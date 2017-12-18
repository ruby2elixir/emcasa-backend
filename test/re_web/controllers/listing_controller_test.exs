defmodule ReWeb.ListingControllerTest do
  use ReWeb.ConnCase

  alias Re.{
    Address,
    Listing
  }
  import Re.Factory

  @valid_attrs %{type: "apto", score: 3, floor: "H1", complement: "basement", bathrooms: 2, description: "some content", price: 1_000_000, rooms: 4, area: 140, garage_spots: 3,}
  @valid_address_attrs %{street: "A Street", street_number: "100", neighborhood: "A Neighborhood", city: "A City", state: "ST", postal_code: "12345-678", lat: "25", lng: "25"}
  @invalid_attrs %{}

  def fixture(:listing) do
    {:ok, listing} = insert(:listing)
    listing
  end

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn =
      conn
      |> put_req_header("accept", "application/json")

    authenticated_conn = put_req_header(conn, "authorization", "Token #{jwt}")
    {:ok, authenticated_conn: authenticated_conn, unauthenticated_conn: conn}
  end

  test "lists all entries on index", %{authenticated_conn: conn} do
    conn = get conn, listing_path(conn, :index)
    assert json_response(conn, 200)["listings"] == []
  end

  describe "show" do
    test "shows chosen resource", %{authenticated_conn: conn} do
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

    test "do not show inactive listing", %{authenticated_conn: conn} do
      address = insert(:address)
      image = insert(:image)
      listing = insert(:listing, images: [image], address: address, is_active: false)
      conn = get conn, listing_path(conn, :show, listing)
      json_response(conn, 404)
    end

    test "renders page not found when id is nonexistent", %{authenticated_conn: conn} do
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
    test "edits chosen resource", %{authenticated_conn: conn} do
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

    test "renders page not found when id is nonexistent", %{authenticated_conn: conn} do
      conn = get conn, listing_path(conn, :edit, -1)
      json_response(conn, 404)
    end

    test "does not list listing for unauthenticated requests even if not authenticated", %{unauthenticated_conn: conn} do
      address = insert(:address)
      image = insert(:image)
      listing = insert(:listing, images: [image], address: address)

      conn = get conn, listing_path(conn, :edit, listing)
      json_response(conn, 403)
    end
  end

  describe "create" do
    test "creates and renders resource when data is valid", %{authenticated_conn: conn} do
      conn = post conn, listing_path(conn, :create), listing: @valid_attrs, address: @valid_address_attrs
      response = json_response(conn, 201)
      assert response["listing"]["id"]
      assert Repo.get_by(Listing, @valid_attrs)
    end

    test "creates and renders resource with existing address", %{authenticated_conn: conn} do
      insert(:address, @valid_address_attrs)
      conn = post conn, listing_path(conn, :create), listing: @valid_attrs, address: @valid_address_attrs
      response = json_response(conn, 201)
      assert response["listing"]["id"]
      assert Repo.get_by(Listing, @valid_attrs)
      assert length(Repo.all(Address)) == 1
    end

    test "does not create resource and renders errors when data is invalid", %{authenticated_conn: conn} do
      conn = post(conn, listing_path(conn, :create), %{listing: @invalid_attrs, address: @valid_address_attrs})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "does not create resource when user is not authenticated", %{unauthenticated_conn: conn} do
      conn = post(conn, listing_path(conn, :create), %{listing: @valid_attrs, address: @valid_address_attrs})
      json_response(conn, 403)
      refute Repo.get_by(Listing, @valid_attrs)
    end
  end

  describe "update" do
    test "updates and renders chosen resource when data is valid", %{authenticated_conn: conn} do
      listing = insert(:listing, address: build(:address))
      conn = put conn, listing_path(conn, :update, listing),
        id: listing.id, listing: @valid_attrs, address: @valid_address_attrs
      assert json_response(conn, 200)["listing"]["id"]
      assert Repo.get_by(Listing, @valid_attrs)
    end

    test "does not update chosen resource and renders errors when data is invalid", %{authenticated_conn: conn} do
      address = Repo.insert! %Re.Address{}
      listing = Repo.insert! %Listing{address_id: address.id}

      conn = put(conn, listing_path(conn, :update, listing), %{id: listing.id, listing: @invalid_attrs, address: @valid_address_attrs})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "does not update resource when user is not authenticated", %{unauthenticated_conn: conn} do
      listing = insert(:listing, address: build(:address))
      conn = put conn, listing_path(conn, :update, listing),
        id: listing.id, listing: @valid_attrs, address: @valid_address_attrs
      assert json_response(conn, 403)
      refute Repo.get_by(Listing, @valid_attrs)
    end
  end

  describe "delete" do
    test "deletes chosen resource", %{authenticated_conn: conn} do
      listing = insert(:listing)
      conn = delete conn, listing_path(conn, :delete, listing)
      assert response(conn, 204)
      refute Repo.get(Listing, listing.id)
    end

    test "does not delete resource when user is not authenticated", %{unauthenticated_conn: conn} do
      listing = insert(:listing)
      conn = delete conn, listing_path(conn, :delete, listing)
      assert response(conn, 403)
      assert Repo.get(Listing, listing.id)
    end
  end
end
