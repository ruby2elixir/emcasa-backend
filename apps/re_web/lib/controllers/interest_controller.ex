defmodule ReWeb.InterestController do
  use ReWeb, :controller

  alias Re.Interests

  action_fallback(ReWeb.FallbackController)

  def create(conn, %{"listing_id" => listing_id, "interest" => params}) do
    with params <- Map.merge(params, %{"listing_id" => listing_id}),
         {:ok, interest} <- Interests.show_interest(params) do
      conn
      |> put_status(:created)
      |> render("show.json", interest: interest)
    end
  end
end
