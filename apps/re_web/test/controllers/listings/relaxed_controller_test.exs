defmodule ReWeb.RelaxedControllerTest do
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

  describe "index" do
    test "relaxed listings for admin user", %{admin_conn: conn} do
      %{id: id1} =
        insert(
          :listing,
          address: build(:address, neighborhood: "Ipanema"),
          price: 105_000,
          liquidity_ratio: 4.0
        )

      %{id: id2} =
        insert(
          :listing,
          address: build(:address, neighborhood: "Copacabana"),
          price: 105_000,
          liquidity_ratio: 3.0
        )

      conn = get(conn, relaxed_path(conn, :index), max_price: 1_000_000)

      response = json_response(conn, 200)
      assert [%{"id" => ^id1}, %{"id" => ^id2}] = response["listings"]
      assert %{"max_price" => 1_100_000} = response["filters"]
    end

    test "relaxed listings for non user", %{admin_conn: conn} do
      %{id: id1} =
        insert(
          :listing,
          address: build(:address, neighborhood: "Ipanema"),
          price: 105_000,
          liquidity_ratio: 4.0
        )

      %{id: id2} =
        insert(
          :listing,
          address: build(:address, neighborhood: "Copacabana"),
          price: 105_000,
          liquidity_ratio: 3.0
        )

      conn = get(conn, relaxed_path(conn, :index), max_price: 1_000_000)

      response = json_response(conn, 200)
      assert [%{"id" => ^id1}, %{"id" => ^id2}] = response["listings"]
      assert %{"max_price" => 1_100_000} = response["filters"]
    end

    test "relaxed listings for unauthenticated request", %{conn: conn} do
      %{id: id1} =
        insert(
          :listing,
          address: build(:address, neighborhood: "Ipanema"),
          price: 105_000,
          liquidity_ratio: 4.0
        )

      %{id: id2} =
        insert(
          :listing,
          address: build(:address, neighborhood: "Copacabana"),
          price: 105_000,
          liquidity_ratio: 3.0
        )

      conn = get(conn, relaxed_path(conn, :index), max_price: 1_000_000)
      response = json_response(conn, 200)
      assert [%{"id" => ^id1}, %{"id" => ^id2}] = response["listings"]
      assert %{"max_price" => 1_100_000} = response["filters"]
    end
  end
end
