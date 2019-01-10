defmodule ReWeb.Exporters.Zap.PlugTest do
  use ReWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  @empty_listings ~s|<?xml version="1.0" encoding="UTF-8"?><Carga xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><Imoveis/></Carga>|

  describe "with state and city slugs on path" do
    test "should export zap XML", %{conn: conn} do
      conn = get(conn, "/exporters/zap/rio-de-janeiro/rio-de-janeiro")

      assert response(conn, 200) == @empty_listings
    end
  end
end
