defmodule ReWeb.Router do
  use ReWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, realm: "Token"
    plug Guardian.Plug.LoadResource
  end

  scope "/", ReWeb do
    pipe_through :api

    post "/users/login", SessionController, :create
    resources "/listings", ListingController, except: [:new] do
      resources "/images", ImageController, only: [:index, :create, :delete]
    end
    put "/listings/:listing_id/image_order", ListingController, :order
    resources "/neighborhoods", NeighborhoodController, only: [:index]
    resources "/users", UserController, except: [:new, :edit, :create]
    resources "/listings_users", ListingUserController, only: [:create]
  end

  if Mix.env == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview, [base_path: "/dev/mailbox"]
    end
  end
end
