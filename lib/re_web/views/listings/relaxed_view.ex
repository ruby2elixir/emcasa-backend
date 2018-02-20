defmodule ReWeb.RelaxedView do
  use ReWeb, :view

  def render("index.json", %{
        listings: listings,
        filters: filters,
        page_number: page_number,
        page_size: page_size,
        total_pages: total_pages,
        total_entries: total_entries
      }) do
    %{
      listings: render_many(listings, ReWeb.ListingView, "listing.json"),
      filters: filters,
      page_number: page_number,
      page_size: page_size,
      total_pages: total_pages,
      total_entries: total_entries
    }
  end
end
