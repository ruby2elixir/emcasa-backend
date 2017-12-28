defmodule ReWeb.Router do
  use ReWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug ProperCase.Plug.SnakeCaseParams # TODO: maybe remove
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
    resources "/addresses", AddressController, except: [:new, :edit]
    resources "/users", UserController, except: [:new, :edit, :create]
    resources "/listings_users", ListingUserController, only: [:create]
  end
end
