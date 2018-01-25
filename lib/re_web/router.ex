defmodule ReWeb.Router do
  use ReWeb, :router

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

    resources "/listings", ListingController, only: [:index, :show] do
      resources("/interests", InterestController, only: [:create])
    end

    get("/featured_listings", FeaturedController, :index)
  end

  scope "/users", ReWeb do
    pipe_through(:public_api)

    put("/confirm", UserController, :confirm)

    post("/login", UserController, :login)
    post("/register", UserController, :register)
    post("/reset_password", UserController, :reset_password)
    post("/redefine_password", UserController, :redefine_password)
  end

  scope "/", ReWeb do
    pipe_through(:private_api)

    resources "/listings", ListingController, except: [:new] do
      resources("/images", ImageController, only: [:index, :create, :delete])
      post("/images/order", ImageController, :order)
    end
  end

  scope "/users", ReWeb do
    pipe_through(:private_api)

    post("/edit_password", UserController, :edit_password)
    put("/change_email", UserController, :change_email)
  end

  if Mix.env() == :dev do
    pipeline :browser do
      plug(:accepts, ["html"])
      plug(:fetch_session)
      plug(:fetch_flash)
      plug(:protect_from_forgery)
      plug(:put_secure_browser_headers)
    end

    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview, base_path: "/dev/mailbox")
    end
  end
end
