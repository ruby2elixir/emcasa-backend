defmodule ReWeb.UserView do
  use ReWeb, :view
  alias ReWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("login.json", %{jwt: jwt, user: user}) do
    %{user: Map.merge(render_one(user, UserView, "user.json"), %{token: jwt})}
  end

  def render("register.json", %{user: user}) do
    %{user: render_one(user, UserView, "user.json")}
  end

  def render("confirm.json", %{user: user}) do
    %{user: render_one(user, UserView, "user.json")}
  end

  def render("reset_password.json", %{user: user}) do
    %{user: render_one(user, UserView, "user.json")}
  end

  def render("redefine_password.json", %{user: user}) do
    %{user: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, name: user.name, email: user.email, phone: user.phone, role: user.role}
  end

  def render("error.json", %{message: message}) do
    %{message: message}
  end
end
