defmodule ReWeb.Exporters.Vivareal.PlugTest do
  use ReWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  @empty_listings ~s|<?xml version="1.0" encoding="UTF-8"?><ListingDataFeed xmlns="http://www.vivareal.com/schemas/1.0/VRSync" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.vivareal.com/schemas/1.0/VRSync  http://xml.vivareal.com/vrsync.xsd"><Header><Provider>EmCasa</Provider><Email>rodrigo.nonose@emcasa.com</Email><ContactName>Rodrigo Nonose</ContactName></Header><Listings/></ListingDataFeed>|

  test "should export vivareal XML", %{conn: conn} do
    conn = get(conn, "/exporters/vivareal")

    assert response(conn, 200) == @empty_listings
  end
end
