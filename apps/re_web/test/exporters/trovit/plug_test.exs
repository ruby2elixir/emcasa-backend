defmodule ReWeb.Exporters.Trovit.PlugTest do
  use ReWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  @empty_listings ~s|<?xml version="1.0" encoding="UTF-8"?><trovit/>|
  @error_message ~s|<?xml version="1.0" encoding="UTF-8"?><error>Expect state and city on path</error>|

  describe "with active city and state slugs on path" do
    test "should render listings XML", %{conn: conn} do
      conn = get(conn, "/exporters/trovit/rj/rio-de-janeiro")

      assert response(conn, 200) == @empty_listings
    end
  end

  describe "with nonexistent city and state slugs on path" do
    test "should return an empty XML", %{conn: conn} do
      conn = get(conn, "/exporters/trovit/rs/porto-alegre")

      assert response(conn, 200) == @empty_listings
    end
  end

  describe "without city and state slugs on path" do
    test "should return not found error", %{conn: conn} do
      conn = get(conn, "/exporters/trovit")

      assert response(conn, 404) == @error_message
    end
  end

  describe "with invalid slug" do
    test "should return not found error", %{conn: conn} do
      conn = get(conn, "/exporters/trovit/invalid")

      assert response(conn, 404) == @error_message
    end
  end
end
