defmodule ReWeb.SearchController do
  use ReWeb, :controller
  use ReWeb.GuardedController

  alias Re.Listings

  action_fallback(ReWeb.FallbackController)

  plug(Guardian.Plug.EnsureAuthenticated)

  def index(conn, _params, user) do
    with :ok <- authorize(user) do
      page = Listings.paginated()

      render(
        conn,
        ReWeb.ListingView,
        "paginated_index.json",
        listings: page.entries,
        page_number: page.page_number,
        page_size: page.page_size,
        total_pages: page.total_pages,
        total_entries: page.total_entries
      )
    end
  end

  def authorize(%{role: "admin"}), do: :ok
  def authorize(nil), do: {:error, :unauthorized}
  def authorize(_), do: {:error, :forbidden}
end
