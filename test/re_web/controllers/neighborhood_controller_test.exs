defmodule ReWeb.NeighborhoodControllertest do
  use ReWeb.ConnCase

  alias Re.{
    Address,
    Listing
  }

  import Re.Factory

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn =
      conn
      |> put_req_header("accept", "application/json")

    authenticated_conn = put_req_header(conn, "authorization", "Token #{jwt}")
    {:ok, authenticated_conn: authenticated_conn, unauthenticated_conn: conn}
  end

  test "lists all entries on index", %{authenticated_conn: conn} do
    conn = get conn, neighborhood_path(conn, :index)
    assert json_response(conn, 200)["neighborhoods"] == []
  end
end
