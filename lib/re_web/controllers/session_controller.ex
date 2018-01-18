defmodule ReWeb.SessionController do
  use ReWeb, :controller

  alias Re.Accounts.Auth
  alias ReWeb.Guardian

  action_fallback(ReWeb.FallbackController)

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    with {:ok, user} <- Auth.find_user(email),
         :ok <- Auth.check_password(password, user),
         {:ok, jwt, _full_claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render(ReWeb.UserView, "login.json", jwt: jwt, user: user)
    end
  end
end
