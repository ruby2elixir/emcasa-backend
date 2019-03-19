defmodule ReWeb.Exporters.Zap.PlugTest do
  use ReWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  @empty_listings ~s|<?xml version="1.0" encoding="UTF-8"?><Carga xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><Imoveis/></Carga>|
  @error_message ~s|<?xml version="1.0" encoding="UTF-8"?><error>Expect state and city on path</error>|

  describe "with active state and city slugs on path" do
    test "should export zap XML", %{conn: conn} do
      conn = get(conn, "/exporters/zap/rj/rio-de-janeiro")

      assert response(conn, 200) == @empty_listings
    end
  end

  describe "with inactive state and city slugs on path" do
    test "should export zap XML", %{conn: conn} do
      conn = get(conn, "/exporters/zap/rs/porto-alegre")

      assert response(conn, 200) == @empty_listings
    end
  end

  describe "without city and state slug on path" do
    test "should return not found error", %{conn: conn} do
      conn = get(conn, "/exporters/zap")

      assert response(conn, 404) == @error_message
    end
  end

  describe "with invalid path" do
    test "should return not found error", %{conn: conn} do
      conn = get(conn, "/exporters/zap/invalid")

      assert response(conn, 404) == @error_message
    end
  end
end
