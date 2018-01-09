defmodule ReWeb.NeighborhoodControllerTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.Guardian

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn =
      conn
      |> put_req_header("accept", "application/json")

    authenticated_conn = put_req_header(conn, "authorization", "Token #{jwt}")
    {:ok, authenticated_conn: authenticated_conn, unauthenticated_conn: conn}
  end

  describe "index" do
    test "succeeds if authenticated", %{authenticated_conn: conn} do
      address = insert(:address)
      conn = get conn, neighborhood_path(conn, :index)
      assert json_response(conn, 200)["neighborhoods"] == [address.neighborhood]
    end

    test "succeeds if unauthenticated", %{unauthenticated_conn: conn} do
      address = insert(:address)
      insert(:address, postal_code: "12345-678", street: "Another street")
      conn = get conn, neighborhood_path(conn, :index)
      assert json_response(conn, 200)["neighborhoods"] == [address.neighborhood]
    end
  end
end
