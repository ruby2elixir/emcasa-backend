defmodule ReWeb.Router do
  use Re.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ReWeb do
    pipe_through :api

    resources "/listings", ListingController, except: [:new, :edit]
  end
end
