defmodule ReWeb.ListingControllerTest do
  use ReWeb.ConnCase

  alias ReWeb.Listing
  import Re.Factory

  # @valid_attrs %{description: "some content", name: "some content", price: 1_000_000, rooms: 4, area: 140, garage_spots: 3,}
  @valid_address_attrs %{street: "A Street", street_number: "100", neighborhood: "A Neighborhood", city: "A City", state: "ST", postal_code: "12345-678", lat: "25", lng: "25"}
  @invalid_attrs %{}

  def fixture(:listing) do
    {:ok, listing} = insert(:listing)
    listing
  end

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    {:ok, conn: put_req_header(conn, "accept", "application/json"), jwt: jwt}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, listing_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    address = insert(:address)
    image = insert(:image)
    listing = insert(:listing, images: [image], address: address)
    conn = get conn, listing_path(conn, :show, listing)
    assert json_response(conn, 200)["data"] ==
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

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, listing_path(conn, :show, -1)
    end
  end

  # test "creates and renders resource when data is valid", %{conn: conn} do
  #   conn = post conn, listing_path(conn, :create), listing: @valid_attrs
  #   assert json_response(conn, 201)["data"]["id"]
  #   assert Repo.get_by(Listing, @valid_attrs)
  # end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, jwt: jwt} do
    conn = conn |> put_req_header("authorization", "Token #{jwt}")
    conn = post(conn, listing_path(conn, :create), %{listing: @invalid_attrs, address: @valid_address_attrs})
    assert json_response(conn, 422)["errors"] != %{}
  end

  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
  #   listing = Repo.insert! %Listing{}
  #   conn = put conn, listing_path(conn, :update, listing), listing: @valid_attrs
  #   assert json_response(conn, 200)["data"]["id"]
  #   assert Repo.get_by(Listing, @valid_attrs)
  # end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, jwt: jwt} do
    address = Repo.insert! %ReWeb.Address{}
    listing = Repo.insert! %Listing{address_id: address.id}

    conn = conn |> put_req_header("authorization", "Token #{jwt}")
    conn = put(conn, listing_path(conn, :update, listing), %{id: listing.id, listing: @invalid_attrs, address: @valid_address_attrs})
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn, jwt: jwt} do
    listing = insert(:listing)
    conn = conn |> put_req_header("authorization", "Token #{jwt}")
    conn = delete conn, listing_path(conn, :delete, listing)
    assert response(conn, 204)
    refute Repo.get(Listing, listing.id)
  end

end
