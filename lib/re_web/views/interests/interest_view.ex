defmodule ReWeb.InterestView do
  use ReWeb, :view

  def render("index.json", %{interests: interests}) do
    %{data: render_many(interests, ReWeb.InterestView, "interest.json")}
  end

  def render("show.json", %{interest: interest}) do
    %{data: render_one(interest, ReWeb.InterestView, "interest.json")}
  end

  def render("interest.json", %{interest: interest}) do
    %{
      id: interest.id,
      name: interest.name,
      email: interest.email,
      phone: interest.phone,
      message: interest.message,
      listing_id: interest.listing_id
    }
  end
end
