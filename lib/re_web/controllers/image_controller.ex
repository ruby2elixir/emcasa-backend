defmodule ReWeb.ImageController do
  use ReWeb, :controller
  use Guardian.Phoenix.Controller

  alias Re.Images

  # plug Guardian.Plug.EnsureAuthenticated,
  #   %{handler: ReWeb.SessionController}

  def index(conn, %{"listing_id" => listing_id}, _user, _full_claims) do
    render(conn, "index.json", images: Images.all(listing_id))
  end
end
