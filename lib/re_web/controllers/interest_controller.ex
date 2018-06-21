defmodule ReWeb.InterestController do
  use ReWeb, :controller

  alias Re.{
    Interests,
    Listings
  }

  @emails Application.get_env(:re, :emails, ReWeb.Notifications.Emails)

  action_fallback(ReWeb.FallbackController)

  def create(conn, %{"listing_id" => listing_id, "interest" => params}) do
    with {:ok, listing} <- Listings.get(listing_id),
         {:ok, interest} <- Interests.show_interest(listing_id, params),
         interest <- Interests.preload(interest) do
      notify_interest(listing, interest)

      conn
      |> put_status(:created)
      |> render("show.json", interest: interest)
    end
  end

  defp notify_interest(%{is_active: true}, interest), do: @emails.notify_interest(interest)
  defp notify_interest(_, _interest), do: :nothing
end
