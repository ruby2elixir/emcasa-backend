defmodule ReWeb.Exporters.Imovelweb.PlugTest do
  use ReWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  @empty_listings ~s|<?xml version="1.0" encoding="UTF-8"?><Carga xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><Imoveis/></Carga>|
  @error_message ~s|<?xml version="1.0" encoding="UTF-8"?><error>Expect state and city on path</error>|

  describe "with active city and state slugs on path" do
    test "should render listings XML", %{conn: conn} do
      conn = get(conn, "/exporters/imovelweb/rj/rio-de-janeiro")

      assert response(conn, 200) == @empty_listings
    end
  end

  describe "with nonexistent city and state slugs on path" do
    test "should return an empty XML", %{conn: conn} do
      conn = get(conn, "/exporters/imovelweb/rs/porto-alegre")

      assert response(conn, 200) == @empty_listings
    end
  end

  describe "without city and state slugs on path" do
    test "should return not found error", %{conn: conn} do
      conn = get(conn, "/exporters/imovelweb")

      assert response(conn, 404) == @error_message
    end
  end

  describe "with invalid slug" do
    test "should return not found error", %{conn: conn} do
      conn = get(conn, "/exporters/imovelweb/invalid")

      assert response(conn, 404) == @error_message
    end
  end
end
