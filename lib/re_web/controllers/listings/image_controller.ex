defmodule ReWeb.ImageController do
  use ReWeb, :controller
  use ReWeb.GuardedController

  alias Re.{
    Images,
    Listings
  }

  action_fallback(ReWeb.FallbackController)

  plug(
    Guardian.Plug.EnsureAuthenticated
    when action in [:create, :delete, :order]
  )

  def index(conn, %{"listing_id" => listing_id}, user) do
    with {:ok, listing} <- Listings.get(listing_id),
         :ok <- Bodyguard.permit(Images, :index_images, user, listing),
         images <- Images.all(listing_id),
         do: render(conn, "index.json", images: images)
  end

  def create(conn, %{"listing_id" => listing_id, "image" => image_params}, user) do
    with {:ok, listing} <- Listings.get(listing_id),
         :ok <- Bodyguard.permit(Images, :create_images, user, listing),
         {:ok, image} <- Images.insert(image_params, listing.id) do
      conn
      |> put_status(:created)
      |> render("create.json", image: image)
    end
  end

  def delete(conn, %{"listing_id" => listing_id, "id" => image_id}, user) do
    with {:ok, listing} <- Listings.get(listing_id),
         :ok <- Bodyguard.permit(Images, :delete_images, user, listing),
         {:ok, image} <- Images.get(image_id),
         {:ok, _image} <- Images.delete(image),
         do: send_resp(conn, :no_content, "")
  end

  def order(conn, %{"listing_id" => id, "images" => images_params}, user) do
    with {:ok, listing} <- Listings.get(id),
         :ok <- Bodyguard.permit(Listings, :order_listing_images, user, listing),
         :ok <- Images.update_per_listing(listing, images_params),
         do: send_resp(conn, :no_content, "")
  end
end
