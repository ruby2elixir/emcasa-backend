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

  def create(conn, %{"listing_id" => listing_id, "image" => image_params}, _user, _full_claims) do
    case Images.insert(image_params, listing_id) do
      {:ok, image} ->
        conn
        |> put_status(:created)
        |> render("create.json", image: image)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ReWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"listing_id" => listing_id, "id" => image_id}, _user, _full_claims) do
    with {:ok, image} <- Images.get_per_listing(listing_id, image_id),
         {:ok, _image} <- Images.delete(image),
      do: send_resp(conn, :no_content, "")
  end
end
