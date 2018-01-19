defmodule ReWeb.Router do
  use ReWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :public_api do
    plug(:accepts, ["json"])
  end

  pipeline :private_api do
    plug(:accepts, ["json"])
    plug(ReWeb.GuardianPipeline)
  end

  scope "/", ReWeb do
    pipe_through(:public_api)

    resources("/neighborhoods", NeighborhoodController, only: [:index])
    resources("/listings", ListingController, only: [:index, :show])
    resources("/interests", InterestController, only: [:create])
    post("/users/login", AuthController, :login)
    post("/users/register", AuthController, :register)
    put("/users/confirm", AuthController, :confirm)
    post("/users/reset_password", AuthController, :reset_password)
    post("/users/redefine_password", AuthController, :redefine_password)
  end

  scope "/", ReWeb do
    pipe_through(:private_api)

    post("/users/edit_password", AuthController, :edit_password)

    resources "/listings", ListingController, except: [:new] do
      resources("/images", ImageController, only: [:index, :create, :delete])
    end

    put("/listings/:listing_id/image_order", ListingController, :order)
  end

  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview, base_path: "/dev/mailbox")
    end
  end
end
