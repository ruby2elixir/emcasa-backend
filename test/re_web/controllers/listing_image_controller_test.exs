defmodule ReWeb.ListingImageControllerTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias Re.Image
  alias ReWeb.Guardian

  @valid_attrs %{filename: "filename.jpg", position: 1}

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    {:ok,
      unauthenticated_conn: conn,
      admin_conn: login_as(conn, insert(:user, email: "admin@email.com", role: "admin")),
      user_conn: login_as(conn, insert(:user, email: "user@email.com", role: "user"))
    }
  end

  describe "index" do
    test "lists all images for a listing", %{admin_conn: conn} do
      address = insert(:address)
      image1 = insert(:image, position: 2)
      image2 = insert(:image, position: 1)
      listing = insert(:listing, images: [image1, image2], address: address)

      conn = get conn, listing_image_path(conn, :index, listing)
      assert json_response(conn, 200)["images"] == [
        %{
          "filename" => image2.filename,
          "id" => image2.id,
          "position" => image2.position
        },
        %{
          "filename" => image1.filename,
          "id" => image1.id,
          "position" => image1.position
        },
      ]
    end

    test "don't list images for unauthenticated requests", %{unauthenticated_conn: conn} do
      address = insert(:address)
      image = insert(:image)
      listing = insert(:listing, images: [image], address: address)

      conn = get conn, listing_image_path(conn, :index, listing)
      json_response(conn, 401)
    end

    test "don't list images for not admin", %{user_conn: conn} do
      address = insert(:address)
      image = insert(:image)
      listing = insert(:listing, images: [image], address: address)

      conn = get conn, listing_image_path(conn, :index, listing)
      json_response(conn, 403)
    end
  end

  describe "create" do
    test "successfully if authenticated", %{admin_conn: conn} do
      listing = insert(:listing)
      conn = post conn, listing_image_path(conn, :create, listing.id), image: @valid_attrs
      response = json_response(conn, 201)
      assert response["image"]["id"]
      assert Repo.get_by(Image, @valid_attrs)
    end

    test "fails if not authenticated", %{unauthenticated_conn: conn} do
      listing = insert(:listing)
      conn = post conn, listing_image_path(conn, :create, listing.id), image: @valid_attrs
      json_response(conn, 401)
    end

    test "fails if not admin", %{user_conn: conn} do
      listing = insert(:listing)
      conn = post conn, listing_image_path(conn, :create, listing.id), image: @valid_attrs
      json_response(conn, 403)
    end

    test "insert with lowest position", %{admin_conn: conn} do
      image1 = insert(:image, %{position: 1})
      image2 = insert(:image, %{position: 2})
      listing = insert(:listing, images: [image1, image2])
      conn = post conn, listing_image_path(conn, :create, listing.id), image: @valid_attrs
      response = json_response(conn, 201)
      assert inserted_image = Repo.get(Image, response["image"]["id"])
      assert inserted_image.position == 0
    end
  end

  describe "delete" do
    test "successfully if authenticated", %{admin_conn: conn} do
      image = insert(:image)
      listing = insert(:listing, images: [image])
      conn = delete conn, listing_image_path(conn, :delete, listing, image)
      response(conn, 204)
      refute Repo.get(Image, image.id)
    end

    test "fails if not authenticated", %{unauthenticated_conn: conn} do
      image = insert(:image)
      listing = insert(:listing, images: [image])
      conn = delete conn, listing_image_path(conn, :delete, listing, image)
      json_response(conn, 401)
    end

    test "fails if not admin", %{user_conn: conn} do
      image = insert(:image)
      listing = insert(:listing, images: [image])
      conn = delete conn, listing_image_path(conn, :delete, listing, image)
      json_response(conn, 403)
    end
  end
end
