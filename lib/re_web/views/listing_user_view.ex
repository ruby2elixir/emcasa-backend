defmodule ReWeb.ListingUserView do
  use ReWeb, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, ReWeb.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, ReWeb.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone}
  end
end
