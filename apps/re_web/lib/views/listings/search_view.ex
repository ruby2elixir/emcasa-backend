defmodule ReWeb.SearchView do
  use ReWeb, :view

  def render("search.json", %{results: %{"hits" => %{"hits" => hits}}}) do
    %{results: render_many(hits, ReWeb.SearchView, "search_listing.json")}
  end

  def render("search_listing.json", %{search: %{"_id" => id, "_source" => listing}}) do
    %{
      id: id,
      type: listing["type"],
      complement: listing["complement"],
      description: listing["description"],
      floor: listing["floor"],
      price: listing["price"],
      property_tax: listing["property_tax"],
      maintenance_fee: listing["maintenance_fee"],
      area: listing["area"],
      rooms: listing["rooms"],
      bathrooms: listing["bathrooms"],
      restrooms: listing["restrooms"],
      garage_spots: listing["garage_spots"],
      matterport_code: listing["matterport_code"],
      suites: listing["suites"],
      dependencies: listing["dependencies"],
      balconies: listing["balconies"],
      has_elevator: listing["has_elevator"],
      is_exclusive: listing["is_exclusive"],
      is_release: listing["is_release"],
      inserted_at: listing["inserted_at"],
      street: listing["street"],
      street_number: listing["street_number"],
      neighborhood: listing["neighborhood"],
      city: listing["city"],
      state: listing["state"],
      postal_code: listing["postal_code"],
      lat: listing["lat"],
      lng: listing["lng"]
    }
  end
end
