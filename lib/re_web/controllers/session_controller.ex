defmodule ReWeb.SessionController do
  use ReWeb, :controller

  alias Re.Accounts.Auth
  alias ReWeb.Guardian

  def create(conn, params) do
    case Auth.find_user_and_check_password(params) do
      {:ok, user} ->
        {:ok, jwt, _full_claims} = user |> Guardian.encode_and_sign()

        conn
        |> put_status(:created)
        |> render(ReWeb.UserView, "login.json", jwt: jwt, user: user)

      {:error, message} ->
        conn
        |> put_status(401)
        |> render(ReWeb.UserView, "error.json", message: message)
    end
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:forbidden)
    |> render(ReWeb.UserView, "error.json", message: "Not Authenticated")
  end
end
