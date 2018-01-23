defmodule ReWeb.NeighborhoodControllerTest do
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
    test "succeeds if authenticated", %{authenticated_conn: conn} do
      address = insert(:address)
      insert(:listing, address: address)
      conn = get(conn, neighborhood_path(conn, :index))
      assert json_response(conn, 200)["neighborhoods"] == [address.neighborhood]
    end

    test "succeeds if unauthenticated", %{unauthenticated_conn: conn} do
      address1 = insert(:address, neighborhood: "Copacabana")
      address2 = insert(:address, neighborhood: "Copacabana")
      insert(:listing, address: address1)
      insert(:listing, address: address2)
      conn = get(conn, neighborhood_path(conn, :index))
      assert json_response(conn, 200)["neighborhoods"] == ["Copacabana"]
    end
  end
end
