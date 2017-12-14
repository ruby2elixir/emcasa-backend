defmodule ReWeb.ListingImageControllerTest do
  use ReWeb.ConnCase

  import Re.Factory

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Token #{jwt}")
    {:ok, conn: conn}
  end

  test "lists all images for a listing", %{conn: conn} do
    address = insert(:address)
    image = insert(:image)
    listing = insert(:listing, images: [image], address: address)

    conn = get conn, listing_image_path(conn, :index, listing)
    assert json_response(conn, 200)["images"] == [
      %{
        "filename" => image.filename,
        "id" => image.id,
        "position" => image.position
      }
    ]
  end
end
