defmodule ReWeb.SitemapController do
  use ReWeb, :controller

  def index(conn, _params) do
    render(conn, "index.json", listings: Re.Listings.all())
  end
end
