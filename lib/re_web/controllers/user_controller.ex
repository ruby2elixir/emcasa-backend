defmodule ReWeb.UserController do
  use ReWeb, :controller
  use ReWeb.GuardedController

  alias Re.Accounts.{
    Auth,
    Users
  }

  alias ReWeb.{
    Mailer,
    UserEmail
  }

  action_fallback(ReWeb.FallbackController)

  plug(
    Guardian.Plug.EnsureAuthenticated
    when action in [:change_email, :edit_password]
  )

  def login(conn, %{"user" => %{"email" => email, "password" => password}}, _user) do
    with {:ok, user} <- Auth.find_user(email),
         :ok <- Auth.check_password(password, user),
         {:ok, jwt, _full_claims} <- ReWeb.Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render(ReWeb.UserView, "login.json", jwt: jwt, user: user)
    end
  end

  def register(conn, %{"user" => params}, _user) do
    with {:ok, user} <- Users.create(params) do
      user
      |> UserEmail.confirm()
      |> Mailer.deliver()

      conn
      |> put_status(:created)
      |> render(ReWeb.UserView, "show.json", user: user)
    end
  end

  def confirm(conn, %{"user" => %{"token" => token}}, _user) do
    with {:ok, user} <- Users.confirm(token) do
      user
      |> UserEmail.welcome()
      |> Mailer.deliver()

      render(conn, ReWeb.UserView, "show.json", user: user)
    end
  end

  def reset_password(conn, %{"user" => %{"email" => email}}, _user) do
    with {:ok, user} <- Users.get_by_email(email),
         {:ok, user} <- Users.reset_password(user) do
      user
      |> UserEmail.reset_password()
      |> Mailer.deliver()

      render(conn, ReWeb.UserView, "show.json", user: user)
    end
  end

  def redefine_password(
        conn,
        %{"user" => %{"reset_token" => token, "password" => password}},
        _user
      ) do
    with {:ok, user} <- Users.get_by_reset_token(token),
         {:ok, user} <- Users.redefine_password(user, password) do
      render(conn, ReWeb.UserView, "show.json", user: user)
    end
  end

  def edit_password(
        conn,
        %{
          "user" => %{"current_password" => current_password, "new_password" => new_password}
        },
        %{id: id}
      ) do
    with {:ok, user} <- Users.get(id),
         :ok <- Auth.check_password(current_password, user),
         {:ok, user} <- Users.edit_password(user, new_password) do
      render(conn, ReWeb.UserView, "show.json", user: user)
    end
  end

  def change_email(conn, %{"user" => %{"email" => new_email}}, %{id: id}) do
    with {:ok, user} <- Users.get(id),
         {:ok, user} <- Users.change_email(user, new_email) do
      user
      |> UserEmail.change_email()
      |> Mailer.deliver()

      render(conn, ReWeb.UserView, "show.json", user: user)
    end
  end
end
