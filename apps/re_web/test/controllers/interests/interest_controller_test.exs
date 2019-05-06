defmodule ReWeb.InterestControllerTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias Re.Interest

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create" do
    test "show interest in listing", %{conn: conn} do
      %{id: id} = insert(:interest_type)

      params = %{
        name: "Test Name",
        email: "test@email.com",
        interest_type_id: id
      }

      listing = insert(:listing, address: build(:address))

      conn = post(conn, listing_interest_path(conn, :create, listing.id), interest: params)

      response = json_response(conn, 201)

      interest_id = response["data"]["id"]
      assert interest = Repo.get(Interest, interest_id)
      assert interest.uuid
    end

    test "show interest in invalid listing", %{conn: conn} do
      %{id: id} = insert(:interest_type)

      params = %{
        name: "Test Name",
        email: "test@email.com",
        interest_type_id: id
      }

      conn = post(conn, listing_interest_path(conn, :create, -1), interest: params)

      assert response = json_response(conn, 422)

      assert %{"listing_id" => ["does not exist."]} == response["errors"]
    end
  end
end
