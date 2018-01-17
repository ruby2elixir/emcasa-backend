defmodule ReWeb.InterestController do
  use ReWeb, :controller

  alias Re.Listings.Interests
  alias ReWeb.{
    Mailer,
    UserEmail
  }

  action_fallback ReWeb.FallbackController

  def create(conn, %{"interest" => params}) do
    with {:ok, interest} <- Interests.show_interest(params)
      do
        interest
        |> UserEmail.notify_interest()
        |> Mailer.deliver()

        conn
        |> put_status(:created)
        |> render("show.json", interest: interest)
    end
  end
end
