defmodule ReWeb.FeaturedControllerTest do
  use ReWeb.ConnCase

  alias ReWeb.Guardian

  import Re.Factory

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  describe "featured" do
    test "show top 4 listings", %{
      unauthenticated_conn: conn
    } do
      address = insert(:address)
      insert(:listing, address: address, score: 4, images: [build(:image)])
      insert(:listing, address: address, score: 4, images: [build(:image)])
      %{id: id3} = insert(:listing, address: address, score: 3, images: [build(:image)])
      %{id: id4} = insert(:listing, address: address, score: 2, images: [build(:image)])
      insert(:listing, address: address, score: 1)

      conn = dispatch(conn, @endpoint, "get", "/featured_listings")

      response = json_response(conn, 200)

      assert [%{"id" => _}, %{"id" => _}, %{"id" => ^id3}, %{"id" => ^id4}] = response["listings"]
    end

    test "do not show listing without images", %{
      unauthenticated_conn: conn
    } do
      address = insert(:address)
      insert(:listing, address: address, score: 4, images: [build(:image)])
      insert(:listing, address: address, score: 4, images: [build(:image)])
      %{id: id3} = insert(:listing, address: address, score: 3, images: [build(:image)])
      insert(:listing, address: address, score: 4)
      %{id: id5} = insert(:listing, address: address, score: 2, images: [build(:image)])
      insert(:listing, address: address, score: 1)

      conn = dispatch(conn, @endpoint, "get", "/featured_listings")

      response = json_response(conn, 200)

      assert [%{"id" => _}, %{"id" => _}, %{"id" => ^id3}, %{"id" => ^id5}] = response["listings"]
    end

    test "do not show inactive listings", %{
      unauthenticated_conn: conn
    } do
      %{id: id1} = insert(:listing, address: build(:address), score: 4, images: [build(:image)])
      %{id: id2} = insert(:listing, address: build(:address), score: 3, images: [build(:image)])
      %{id: id3} = insert(:listing, address: build(:address), score: 2, images: [build(:image)])

      insert(
        :listing,
        address: build(:address),
        score: 4,
        images: [build(:image)],
        is_active: false
      )

      conn = dispatch(conn, @endpoint, "get", "/featured_listings")

      response = json_response(conn, 200)

      assert [%{"id" => ^id1}, %{"id" => ^id2}, %{"id" => ^id3}] = response["listings"]
    end
  end
end
