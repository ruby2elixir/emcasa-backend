defmodule ReWeb.ListingImageControllerTest do
  use ReWeb.ConnCase

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

  test "lists all images for a listing", %{authenticated_conn: conn} do
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
    json_response(conn, 403)
  end

end
