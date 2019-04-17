defmodule ReWeb.InterestTypeControllerTest do
  use ReWeb.ConnCase

  import Re.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "all interest types", %{conn: conn} do
      insert(:interest_type, name: "Call me now")
      insert(:interest_type, name: "Call me at a specific time")
      insert(:interest_type, name: "Contact me through email")
      insert(:interest_type, name: "Contact me through WhatsApp")

      conn = get(conn, interest_type_path(conn, :index))

      data = json_response(conn, 200)["data"]

      assert [
               %{"id" => _, "name" => "Call me now"},
               %{"id" => _, "name" => "Call me at a specific time"},
               %{"id" => _, "name" => "Contact me through email"},
               %{"id" => _, "name" => "Contact me through WhatsApp"}
             ] = Enum.sort(data)
    end
  end
end
