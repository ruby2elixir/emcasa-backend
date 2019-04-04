defmodule ReWeb.RobotsPlugTest do
  use ReWeb.ConnCase

  describe "updated.activity" do
    test "authenticated request", %{conn: conn} do
      conn = get(conn, "/robots.txt")

      assert text_response(conn, 200) == "User-agent: *\nDisallow: /*\n"
    end
  end
end
