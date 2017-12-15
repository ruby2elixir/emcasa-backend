defmodule ReWeb.ImageController do
  use ReWeb, :controller
  use Guardian.Phoenix.Controller

  alias Re.Images

  plug Guardian.Plug.EnsureAuthenticated,
    %{handler: ReWeb.SessionController}

  action_fallback ReWeb.FallbackController

  def index(conn, params, _user, _full_claims) do
    with {:ok, images} <- Images.all(params),
      do: render(conn, "index.json", images: images)
  end
end
