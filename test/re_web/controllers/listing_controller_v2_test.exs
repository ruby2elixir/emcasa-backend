defmodule ReWeb.ListingControllerV2Test do
  use ReWeb.ConnCase

  alias Re.{
    Address,
    Listing
  }

  alias ReWeb.Guardian

  import Re.Factory

  @valid_attrs %{
    type: "Casa",
    floor: "H1",
    complement: "basement",
    bathrooms: 2,
    description: "some content",
    price: 1_000_000,
    property_tax: 500.00,
    maintenance_fee: 300.00,
    rooms: 4,
    area: 140,
    is_exclusive: true
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
    price: -1,
    property_tax: -500.00,
    maintenance_fee: -300.00,
    rooms: -1,
    area: -1,
    garage_spots: -1
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

  describe "create" do
    test "creates and renders resource as admin", %{admin_conn: conn, admin_user: user} do
      conn =
        post(
          conn,
          listing_controller_v2_path(conn, :create),
          listing: @valid_attrs,
          address: @valid_address_attrs
        )

      response = json_response(conn, 201)
      assert response["listing"]["id"]
      assert listing = Repo.get_by(Listing, @valid_attrs)
      assert listing.user_id == user.id
    end

    test "creates and renders resource as user", %{user_conn: conn, user_user: _user} do
      conn =
        post(conn, listing_controller_v2_path(conn, :create), %{
          listing: @valid_attrs,
          address: @valid_address_attrs
        })

      json_response(conn, 403)
    end

    test "creates and renders resource with existing address", %{admin_conn: conn} do
      insert(:address, @valid_address_attrs)

      conn =
        post(
          conn,
          listing_controller_v2_path(conn, :create),
          listing: @valid_attrs,
          address: @valid_address_attrs
        )

      response = json_response(conn, 201)
      assert response["listing"]["id"]
      assert Repo.get_by(Listing, @valid_attrs)
      assert length(Repo.all(Address)) == 1
    end

    test "does not create resource and renders errors when data is invalid", %{admin_conn: conn} do
      conn =
        post(conn, listing_controller_v2_path(conn, :create), %{
          listing: @invalid_attrs,
          address: @valid_address_attrs
        })

      assert json_response(conn, 422)["errors"] != %{}
      assert Repo.all(Listing) == []
    end

    test "does not create resource when user is not authenticated", %{unauthenticated_conn: conn} do
      conn =
        post(conn, listing_controller_v2_path(conn, :create), %{
          listing: @valid_attrs,
          address: @valid_address_attrs
        })

      json_response(conn, 401)
      refute Repo.get_by(Listing, @valid_attrs)
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
          listing_controller_v2_path(conn, :update, listing),
          id: listing.id,
          listing: @valid_attrs,
          address: @valid_address_attrs
        )

      assert json_response(conn, 200)["listing"]["id"]
      assert Repo.get_by(Listing, @valid_attrs)
    end

    test "does not update chosen resource and renders errors when data is invalid", %{
      admin_conn: conn,
      admin_user: user
    } do
      listing = insert(:listing, address: build(:address), user: user)

      conn =
        put(conn, listing_controller_v2_path(conn, :update, listing), %{
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
          listing_controller_v2_path(conn, :update, listing),
          id: listing.id,
          listing: @valid_attrs,
          address: @valid_address_attrs
        )

      assert json_response(conn, 401)
      refute Repo.get_by(Listing, @valid_attrs)
    end

    test "update resource when listing belongs to user", %{user_conn: conn, user_user: user} do
      listing = insert(:listing, address: build(:address), user: user)

      conn =
        put(
          conn,
          listing_controller_v2_path(conn, :update, listing),
          id: listing.id,
          listing: @valid_attrs,
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
          listing_controller_v2_path(conn, :update, listing),
          id: listing.id,
          listing: @valid_attrs,
          address: @valid_address_attrs
        )

      assert json_response(conn, 403)
      refute Repo.get_by(Listing, @valid_attrs)
    end
  end
end
