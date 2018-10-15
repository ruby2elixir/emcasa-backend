defmodule ReWeb.AddressView do
  use ReWeb, :view

  def render("index.json", %{address: address}) do
    %{data: render_many(address, ReWeb.AddressView, "address.json")}
  end

  def render("show.json", %{address: address}) do
    %{data: render_one(address, ReWeb.AddressView, "address.json")}
  end

  def render("address.json", %{address: address}) do
    %{
      id: address.id,
      street: address.street,
      street_number: address.street_number,
      neighborhood: address.neighborhood,
      city: address.city,
      state: address.state,
      postal_code: address.postal_code
    }
  end
end
