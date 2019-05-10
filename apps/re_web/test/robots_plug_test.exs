defmodule ReWeb.RobotsPlugTest do
  use ReWeb.ConnCase

  describe "robots.txt" do
    test "should disallow everything", %{conn: conn} do
      conn = get(conn, "/robots.txt")

      assert text_response(conn, 200) == "User-agent: *\nDisallow: /*\n"
    end
  end
end
