defmodule ReWeb.AdminDashboardController do
  use ReWeb, :controller
  use ReWeb.GuardedController

  alias Re.Listings

  action_fallback(ReWeb.FallbackController)

  plug(
    Guardian.Plug.EnsureAuthenticated
    when action in [:index]
  )

  def index(conn, _params, user) do
    with :ok <- Bodyguard.permit(Listings, :admin_dashboard, user, %{}) do
      render(conn, ReWeb.ListingAdminView, "index_admin.json", listings: Listings.with_stats())
    end
  end
end
