defmodule ReWeb.Exporters.FacebookAds.PlugTest do
  use ReWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  @empty_real_estate ~s|<?xml version="1.0" encoding="UTF-8"?><listings/>|
  @empty_product ~s|<?xml version="1.0" encoding="UTF-8"?><feed xmlns=\"http://www.w3.org/2005/Atom\"/>|
  @error_message ~s|<?xml version="1.0" encoding="UTF-8"?><error>Expect FacebookAds type, state and city on path</error>|

  describe "with active city and state slugs on path" do
    test "should render listings XML for real estate", %{conn: conn} do
      conn = get(conn, "/exporters/facebook-ads/real-estate/rj/rio-de-janeiro")

      assert response(conn, 200) == @empty_real_estate
    end

    test "should render listings XML for product", %{conn: conn} do
      conn = get(conn, "/exporters/facebook-ads/product/rj/rio-de-janeiro")

      assert response(conn, 200) == @empty_product
    end
  end

  describe "with nonexistent city and state slugs on path" do
    test "should return an empty XML for real estate", %{conn: conn} do
      conn = get(conn, "/exporters/facebook-ads/real-estate/rs/porto-alegre")

      assert response(conn, 200) == @empty_real_estate
    end

    test "should return an empty XML for product", %{conn: conn} do
      conn = get(conn, "/exporters/facebook-ads/product/rs/porto-alegre")

      assert response(conn, 200) == @empty_product
    end
  end

  describe "without type, city and state slugs on path" do
    test "should return not found error", %{conn: conn} do
      conn = get(conn, "/exporters/facebook-ads")

      assert response(conn, 404) == @error_message
    end
  end

  describe "with invalid slug" do
    test "should return not found error for real estate", %{conn: conn} do
      conn = get(conn, "/exporters/facebook-ads/real-estate/invalid")

      assert response(conn, 404) == @error_message
    end

    test "should return not found error for product", %{conn: conn} do
      conn = get(conn, "/exporters/facebook-ads/product/invalid")

      assert response(conn, 404) == @error_message
    end
  end
end
