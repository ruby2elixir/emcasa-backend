defmodule ReWeb.HealthCheckTest do
  use ReWeb.ConnCase

  describe "health-check" do
    test "check db", %{conn: conn} do
      conn = get(conn, "/health-check")

      assert [
               %{
                 "error" => nil,
                 "healthy" => true,
                 "name" => "DB",
                 "time" => _
               }
             ] = json_response(conn, 200)
    end
  end
end
