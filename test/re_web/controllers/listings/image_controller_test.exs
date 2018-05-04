defmodule ReWeb.ImageControllerTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias Re.Image
  alias ReWeb.Guardian

  @valid_attrs %{filename: "filename.jpg", position: 1}

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

  describe "index" do
    test "lists active images for a listing", %{admin_conn: conn, admin_user: user} do
      address = insert(:address)
      image1 = insert(:image, position: 2)
      image2 = insert(:image, position: 1)
      image3 = insert(:image, is_active: false)
      listing = insert(:listing, images: [image1, image2, image3], address: address, user: user)

      conn = get(conn, listing_image_path(conn, :index, listing))

      assert json_response(conn, 200)["images"] == [
               %{
                 "filename" => image2.filename,
                 "id" => image2.id,
                 "position" => image2.position,
                 "description" => image2.description
               },
               %{
                 "filename" => image1.filename,
                 "id" => image1.id,
                 "position" => image1.position,
                 "description" => image1.description
               }
             ]
    end

    test "don't list images for unauthenticated requests", %{
      unauthenticated_conn: conn,
      admin_user: user
    } do
      address = insert(:address)
      image = insert(:image)
      listing = insert(:listing, images: [image], address: address, user: user)

      conn = get(conn, listing_image_path(conn, :index, listing))
      json_response(conn, 401)
    end

    test "list images if listing belongs to user", %{user_conn: conn, user_user: user} do
      address = insert(:address)
      image = insert(:image)
      listing = insert(:listing, images: [image], address: address, user: user)

      conn = get(conn, listing_image_path(conn, :index, listing))
      json_response(conn, 200)
    end

    test "does not list images if listing doesn't belong to user", %{
      user_conn: conn,
      admin_user: user
    } do
      address = insert(:address)
      image = insert(:image)
      listing = insert(:listing, images: [image], address: address, user: user)

      conn = get(conn, listing_image_path(conn, :index, listing))
      json_response(conn, 403)
    end
  end

  describe "create" do
    test "successfully if authenticated", %{admin_conn: conn, admin_user: user} do
      listing = insert(:listing, user: user)
      conn = post(conn, listing_image_path(conn, :create, listing.id), image: @valid_attrs)
      response = json_response(conn, 201)
      assert response["image"]["id"]
      assert image = Repo.get_by(Image, @valid_attrs)
      assert image.listing_id == listing.id
    end

    test "fails if not authenticated", %{unauthenticated_conn: conn, admin_user: user} do
      listing = insert(:listing, user: user)
      conn = post(conn, listing_image_path(conn, :create, listing.id), image: @valid_attrs)
      json_response(conn, 401)
    end

    test "create image if listing belongs to user", %{user_conn: conn, user_user: user} do
      listing = insert(:listing, user: user)
      conn = post(conn, listing_image_path(conn, :create, listing.id), image: @valid_attrs)
      response = json_response(conn, 201)
      assert response["image"]["id"]
      assert image = Repo.get_by(Image, @valid_attrs)
      assert image.listing_id == listing.id
    end

    test "does not create image if listing doesn't belong to user", %{
      user_conn: conn,
      admin_user: user
    } do
      listing = insert(:listing, user: user)
      conn = post(conn, listing_image_path(conn, :create, listing.id), image: @valid_attrs)
      json_response(conn, 403)
    end

    test "insert with lowest position", %{admin_conn: conn, admin_user: user} do
      image1 = insert(:image, %{position: 1})
      image2 = insert(:image, %{position: 2})
      listing = insert(:listing, images: [image1, image2], user: user)
      conn = post(conn, listing_image_path(conn, :create, listing.id), image: @valid_attrs)
      response = json_response(conn, 201)
      assert image = Repo.get(Image, response["image"]["id"])
      assert image.listing_id == listing.id
      assert image.position == 0
    end
  end

  describe "delete" do
    test "successfully if authenticated", %{admin_conn: conn, admin_user: user} do
      image = insert(:image)
      listing = insert(:listing, images: [image], user: user)
      conn = delete(conn, listing_image_path(conn, :delete, listing, image))
      response(conn, 204)
      assert image = Repo.get(Image, image.id)
      refute image.is_active
    end

    test "fails if not authenticated", %{unauthenticated_conn: conn, admin_user: user} do
      image = insert(:image)
      listing = insert(:listing, images: [image], user: user)
      conn = delete(conn, listing_image_path(conn, :delete, listing, image))
      json_response(conn, 401)
    end

    test "delete image if listing belongs to user", %{user_conn: conn, user_user: user} do
      image = insert(:image)
      listing = insert(:listing, images: [image], user: user)
      conn = delete(conn, listing_image_path(conn, :delete, listing, image))
      response(conn, 204)
      assert image = Repo.get(Image, image.id)
      refute image.is_active
    end

    test "does not delete image if listing doesn't belong to user", %{
      user_conn: conn,
      admin_user: user
    } do
      image = insert(:image)
      listing = insert(:listing, images: [image], user: user)
      conn = delete(conn, listing_image_path(conn, :delete, listing, image))
      json_response(conn, 403)
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

      conn =
        put(conn, listing_image_path(conn, :order, listing), id: listing.id, images: image_params)

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

      conn =
        put(conn, listing_image_path(conn, :order, listing), id: listing.id, images: image_params)

      assert json_response(conn, 401)
    end

    test "update images order when listing belongs to user", %{user_conn: conn, user_user: user} do
      listing = insert(:listing, user: user)
      [%{id: id1}, %{id: id2}, %{id: id3}] = insert_list(3, :image, listing_id: listing.id)

      image_params = [
        %{id: id1, position: 2},
        %{id: id2, position: 3},
        %{id: id3, position: 1}
      ]

      conn =
        put(
          conn,
          listing_image_path(conn, :order, listing),
          id: listing.id,
          images: image_params
        )

      assert response(conn, 204)
    end

    test "does not update images order when listing doesn't belong to user", %{
      user_conn: conn,
      admin_user: user
    } do
      listing = insert(:listing, user: user)
      [%{id: id1}, %{id: id2}, %{id: id3}] = insert_list(3, :image, listing_id: listing.id)

      image_params = [
        %{id: id1, position: 2},
        %{id: id2, position: 3},
        %{id: id3, position: 1}
      ]

      conn =
        put(
          conn,
          listing_image_path(conn, :order, listing),
          id: listing.id,
          images: image_params
        )

      assert json_response(conn, 403)
    end
  end

  describe "zip" do
    test "download images for admin", %{admin_conn: conn} do
      listing =
        insert(
          :listing,
          images: [
            build(:image, filename: "test1.jpg"),
            build(:image, filename: "test2.jpg"),
            build(:image, filename: "test3.jpg")
          ]
        )

      conn = get(conn, listing_image_path(conn, :zip, listing), id: listing.id)

      assert response(conn, 200)
      assert File.read!("./temp/listing-#{listing.id}/test1.jpg") == "test1.jpg"
      assert File.read!("./temp/listing-#{listing.id}/test2.jpg") == "test2.jpg"
      assert File.read!("./temp/listing-#{listing.id}/test3.jpg") == "test3.jpg"
    end
  end
end
