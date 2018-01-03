defmodule ReWeb.ListingUserController do
  use ReWeb, :controller

  alias Re.{
    UserEmail,
    ListingsUsers,
    Mailer
  }

  action_fallback ReWeb.FallbackController

  def create(conn, %{"user" => user_params, "listing" => %{"id" => listing_id}}) do
    with {:ok, user} <- ListingsUsers.insert_user(user_params),
         {:ok, _} <- ListingsUsers.insert_listing_user(user.id, listing_id)
      do
        user
        |> UserEmail.notify_interest(listing_id)
        |> Mailer.deliver()

        conn
        |> put_status(:created)
        |> render("show.json", user: user)
    end
  end
end
