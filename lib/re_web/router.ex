defmodule ReWeb.Router do
  use ReWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(ReWeb.GuardianPipeline)
  end

  pipeline :graphql do
    plug(ReWeb.Auth.Context)
  end

  pipeline :webhooks do
    plug(:accepts, ["json"])
  end

  scope "/", ReWeb do
    pipe_through(:api)

    resources("/neighborhoods", NeighborhoodController, only: [:index])

    resources "/listings", ListingController, except: [:new] do
      resources("/images", ImageController, only: [:index, :create, :delete])
      resources("/interests", InterestController, only: [:create])
      resources("/related", RelatedController, only: [:index])

      put("/images_orders", ImageController, :order)
      get("/download_images", ImageController, :zip)
    end

    resources("/featured_listings", FeaturedController, only: [:index])
    resources("/admin_dashboard", AdminDashboardController, only: [:index])
    resources("/relaxed_listings", RelaxedController, only: [:index])
    resources("/search", SearchController, only: [:index])
    resources("/interest_types", InterestTypeController, only: [:index])
    resources("/sitemap_listings", SitemapController, only: [:index])
  end

  scope "/users", ReWeb do
    pipe_through(:api)

    post("/login", UserController, :login)
    post("/register", UserController, :register)
    post("/reset_password", UserController, :reset_password)
    post("/redefine_password", UserController, :redefine_password)
    post("/edit_password", UserController, :edit_password)

    put("/change_email", UserController, :change_email)
    put("/confirm", UserController, :confirm)
  end

  scope "/graphql_api" do
    pipe_through :graphql

    if Mix.env() == :dev do
      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: ReWeb.Schema,
        socket: ReWeb.UserSocket,
        interface: :playground
    end

    forward "/", Absinthe.Plug, schema: ReWeb.Schema
  end

  scope "/webhooks" do
    pipe_through :webhooks

    forward("/pipedrive", ReWeb.Integrations.Pipedrive.Plug)
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
