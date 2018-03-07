defmodule ReWeb.InterestTypeView do
  use ReWeb, :view

  def render("index.json", %{interest_types: interest_types}) do
    %{data: render_many(interest_types, ReWeb.InterestTypeView, "interest_type.json")}
  end

  def render("show.json", %{interest_type: interest_type}) do
    %{data: render_one(interest_type, ReWeb.InterestTypeView, "interest_type.json")}
  end

  def render("interest_type.json", %{interest_type: interest_type}) do
    %{
      id: interest_type.id,
      name: interest_type.name,
    }
  end
end
