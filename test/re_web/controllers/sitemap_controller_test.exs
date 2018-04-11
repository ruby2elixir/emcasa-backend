defmodule ReWeb.SitemapControllerTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.Guardian

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "accept", "application/json")

    authenticated_conn = put_req_header(conn, "authorization", "Token #{jwt}")
    {:ok, authenticated_conn: authenticated_conn, unauthenticated_conn: conn}
  end

  describe "index" do
    test "should return listings if authenticated", %{authenticated_conn: conn} do
      address = insert(:address)
      %{id: id1} = insert(:listing, address: address, is_active: true, score: 4)
      %{id: id2} = insert(:listing, address: address, is_active: true, score: 3)
      %{id: id3} = insert(:listing, address: address, is_active: true, score: 2)
      insert_list(2, :listing, address: address, is_active: false)

      conn = get(conn, sitemap_path(conn, :index))

      assert [
               %{"id" => ^id1, "updated_at" => _},
               %{"id" => ^id2, "updated_at" => _},
               %{"id" => ^id3, "updated_at" => _}
             ] = json_response(conn, 200)["listings"]
    end

    test "should return listings if not authenticated", %{unauthenticated_conn: conn} do
      address = insert(:address)
      %{id: id1} = insert(:listing, address: address, is_active: true, score: 4)
      %{id: id2} = insert(:listing, address: address, is_active: true, score: 3)
      %{id: id3} = insert(:listing, address: address, is_active: true, score: 2)
      insert_list(2, :listing, address: address, is_active: false)

      conn = get(conn, sitemap_path(conn, :index))

      assert [
               %{"id" => ^id1, "updated_at" => _},
               %{"id" => ^id2, "updated_at" => _},
               %{"id" => ^id3, "updated_at" => _}
             ] = json_response(conn, 200)["listings"]
    end
  end
end
