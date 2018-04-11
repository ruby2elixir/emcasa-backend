defmodule ReWeb.InterestController do
  use ReWeb, :controller

  alias Re.Interests

  alias ReWeb.{
    Mailer,
    UserEmail
  }

  action_fallback(ReWeb.FallbackController)

  def create(conn, %{"listing_id" => listing_id, "interest" => params}) do
    with {:ok, interest} <- Interests.show_interest(listing_id, params),
         interest <- Interests.preload(interest) do
      interest
      |> UserEmail.notify_interest()
      |> Mailer.deliver()

      conn
      |> put_status(:created)
      |> render("show.json", interest: interest)
    end
  end
end
