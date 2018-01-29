defmodule ReWeb.RelatedControllerTest do
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

  describe "show" do
    test "related listings for admin user", %{admin_conn: conn} do
      listing =
        insert(
          :listing,
          address: build(:address),
          type: "Apartamento",
          rooms: 3,
          bathrooms: 3,
          garage_spots: 3
        )

      %{id: id2} =
        insert(
          :listing,
          address: build(:address),
          type: "Apartamento",
          rooms: 3,
          bathrooms: 3,
          garage_spots: 3
        )

      conn = get(conn, listing_related_path(conn, :index, listing))

      response = json_response(conn, 200)
      assert [%{"id" => ^id2}] = response["listings"]
    end
  end
end
