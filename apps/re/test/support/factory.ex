defmodule Re.Factory do
  @moduledoc """
  Use the factories here in tests.
  """

  use ExMachina.Ecto, repo: Re.Repo

  alias Faker.{Name, Address, Internet, Pokemon, Lorem.Shakespeare, Phone, Lorem}

  def user_factory do
    %Re.User{
      uuid: UUID.uuid4(),
      name: Name.name(),
      email: Internet.email(),
      phone: Phone.EnUs.phone(),
      role: "user",
      notification_preferences: %{
        email: true,
        app: true
      }
    }
  end

  def listing_factory do
    price = random(:price)
    area = Enum.random(1..500)
    floor = random(:floor)
    floor_count = random(:floor_count, floor)

    %Re.Listing{
      uuid: UUID.uuid4(),
      type: random(:listing_type),
      complement: Address.secondary_address(),
      description: Shakespeare.hamlet(),
      price: price,
      property_tax: random(:price_float),
      maintenance_fee: random(:price_float),
      floor: floor,
      rooms: Enum.random(1..10),
      bathrooms: Enum.random(1..10),
      restrooms: Enum.random(1..10),
      garage_spots: Enum.random(0..10),
      garage_type: Enum.random(~w(contract condominium)),
      suites: Enum.random(0..10),
      dependencies: Enum.random(0..10),
      balconies: Enum.random(0..10),
      has_elevator: Enum.random([true, false]),
      area: area,
      score: Enum.random(1..4),
      matterport_code: Faker.String.base64(),
      status: "active",
      is_exclusive: Enum.random([true, false]),
      is_release: Enum.random([true, false]),
      is_exportable: Enum.random([true, false]),
      orientation: Enum.random(~w(frontside backside lateral inside)),
      floor_count: floor_count,
      unit_per_floor: Enum.random(1..10),
      sun_period: Enum.random(~w(morning evening)),
      elevators: Enum.random(0..10),
      construction_year: Enum.random(1950..Date.utc_today().year),
      price_per_area: price / area
    }
  end

  def address_factory do
    street_name = Address.street_name()
    street_slug = Re.Slugs.sluggify(street_name)

    neighborhood_name = Pokemon.location()
    neighborhood_slug = Re.Slugs.sluggify(neighborhood_name)

    city_name = Address.city()
    city_slug = Re.Slugs.sluggify(city_name)

    state_name = Address.state_abbr()
    state_slug = Re.Slugs.sluggify(state_name)

    %Re.Address{
      street_number: Address.building_number(),
      street: street_name,
      street_slug: street_slug,
      neighborhood: neighborhood_name,
      neighborhood_slug: neighborhood_slug,
      city: city_name,
      city_slug: city_slug,
      state: state_name,
      state_slug: state_slug,
      postal_code: random_postcode(),
      lat: Address.latitude(),
      lng: Address.longitude()
    }
  end

  def district_factory do
    name = Pokemon.location()

    city_name = Address.city()

    state_name = Address.state_abbr()

    %Re.Addresses.District{
      name: name,
      city: city_name,
      state: state_name,
      description: Shakespeare.hamlet(),
      is_active: true
    }
  end

  def image_factory do
    %Re.Image{
      filename: Internet.image_url(),
      position: Enum.random(-50..50),
      is_active: true,
      description: Shakespeare.hamlet(),
      category: Lorem.word()
    }
  end

  def interest_factory do
    %Re.Interest{
      name: "John Doe"
    }
  end

  def interest_type_factory do
    %Re.InterestType{
      name: Shakespeare.hamlet(),
      enabled: true
    }
  end

  def listing_visualisation_factory, do: %Re.Statistics.ListingVisualization{}

  def listings_favorites_factory, do: %Re.Favorite{}

  def tour_visualisation_factory, do: %Re.Statistics.TourVisualization{}

  def in_person_visit_factory, do: %Re.Statistics.InPersonVisit{}

  def price_history_factory, do: %Re.Listings.PriceHistory{}

  def factors_factory, do: %Re.PriceSuggestions.Factors{}

  def contact_request_factory, do: %Re.Interests.ContactRequest{}

  def price_suggestion_request_factory do
    %Re.PriceSuggestions.Request{
      name: Name.name(),
      email: Internet.email(),
      rooms: Enum.random(1..10),
      bathrooms: Enum.random(1..10),
      garage_spots: Enum.random(0..10),
      area: Enum.random(1..500),
      is_covered: Enum.random([true, false])
    }
  end

  def notify_when_covered_factory, do: %Re.Interests.NotifyWhenCovered{}

  def tour_appointment_factory, do: %Re.Calendars.TourAppointment{}

  def development_factory do
    %Re.Development{
      uuid: UUID.uuid4(),
      name: Name.name(),
      title: Name.name(),
      phase: Enum.random(~w(pre-launch planning building delivered)),
      builder: Name.name(),
      description: Shakespeare.hamlet()
    }
  end

  def unit_factory do
    %Re.Unit{
      uuid: UUID.uuid4(),
      complement: Address.secondary_address(),
      price: random(:price),
      property_tax: random(:price_float),
      maintenance_fee: random(:price_float),
      floor: random(:floor),
      rooms: Enum.random(1..10),
      bathrooms: Enum.random(1..10),
      restrooms: Enum.random(1..10),
      area: Enum.random(1..500),
      garage_spots: Enum.random(0..10),
      garage_type: Enum.random(~w(contract condominium)),
      suites: Enum.random(0..10),
      dependencies: Enum.random(0..10),
      balconies: Enum.random(0..10),
      status: "active"
    }
  end

  def tag_factory do
    name =
      Enum.random(["Air conditioning", "Pool", "Open concept", "Natural light", "Fire place"])

    name_slug = Re.Slugs.sluggify(name)

    %Re.Tag{
      uuid: UUID.uuid4(),
      name: name,
      name_slug: name_slug,
      category: Enum.random(~w(infrastructure location realty view)),
      visibility: "public"
    }
  end

  def grupozap_buyer_lead_factory do
    %Re.Leads.GrupozapBuyer{
      uuid: UUID.uuid4(),
      lead_origin: "VivaReal",
      name: Name.name(),
      email: Internet.email(),
      message: Shakespeare.hamlet()
    }
  end

  defp random_postcode do
    first =
      10_000..99_999
      |> Enum.random()
      |> Integer.to_string()
      |> String.pad_leading(5, "0")

    last =
      100..999
      |> Enum.random()
      |> Integer.to_string()
      |> String.pad_leading(3, "0")

    "#{first}-#{last}"
  end

  defp random(:listing_type), do: Enum.random(~w(Casa Apartamento Cobertura))
  defp random(:price), do: Enum.random(550_000..99_999_999)
  defp random(:price_float), do: Enum.random(1..999_999_999) / 100

  defp random(:floor) do
    1..50
    |> Enum.random()
    |> Integer.to_string()
  end

  defp random(:floor_count, base_floor) do
    base = String.to_integer(base_floor)
    top = base * 2
    Enum.random(base..top)
  end
end
