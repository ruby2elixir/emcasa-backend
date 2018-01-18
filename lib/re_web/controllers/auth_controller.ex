defmodule ReWeb.AuthController do
  use ReWeb, :controller

  alias Re.Accounts.{
    Auth,
    Users
  }

  alias ReWeb.{
    Guardian,
    Mailer,
    UserEmail
  }

  action_fallback(ReWeb.FallbackController)

  def login(conn, %{"user" => %{"email" => email, "password" => password}}) do
    with {:ok, user} <- Auth.find_user(email),
         :ok <- Auth.check_password(password, user),
         {:ok, jwt, _full_claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render(ReWeb.UserView, "login.json", jwt: jwt, user: user)
    end
  end

  def register(conn, %{"user" => params}) do
    with {:ok, user} <- Users.create(params) do
      user
      |> UserEmail.confirm()
      |> Mailer.deliver()

      conn
      |> put_status(:created)
      |> render(ReWeb.UserView, "register.json", user: user)
    end
  end

  def confirm(conn, %{"user" => %{"token" => token}}) do
    with {:ok, user} <- Users.confirm(token) do
      user
      |> UserEmail.welcome()
      |> Mailer.deliver()

      render(conn, ReWeb.UserView, "confirm.json", user: user)
    end
  end

  def reset_password(conn, %{"user" => %{"email" => email}}) do
    with {:ok, user} <- Users.get_by_email(email),
         {:ok, user} <- Users.reset_password(user) do
      user
      |> UserEmail.reset_password()
      |> Mailer.deliver()

      render(conn, ReWeb.UserView, "reset_password.json", user: user)
    end
  end
end
