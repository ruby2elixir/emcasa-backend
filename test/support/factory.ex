defmodule Re.Factory do
  @moduledoc """
  Use the factories here in tests.
  """

  use ExMachina.Ecto, repo: Re.Repo

  alias Faker.{Name, Address, Internet, Pokemon, Lorem.Shakespeare, Phone}
  alias Comeonin.Bcrypt

  def user_factory do
    %Re.User{
      name: Name.name(),
      email: Internet.email(),
      phone: Phone.EnUs.phone(),
      password_hash: Bcrypt.hashpwsalt("password"),
      role: "user",
      confirmation_token: "97971cce-eb6e-418a-8529-e717ca1dcf62",
      confirmed: true
    }
  end

  def listing_factory do
    %Re.Listing{
      type: random(:listing_type),
      complement: Address.secondary_address(),
      description: Shakespeare.hamlet(),
      price: random(:price),
      property_tax: random(:price_float),
      maintenance_fee: random(:price_float),
      floor: random(:floor),
      rooms: Enum.random(1..10),
      bathrooms: Enum.random(1..10),
      garage_spots: Enum.random(0..10),
      suites: Enum.random(0..10),
      dependencies: Enum.random(0..10),
      has_elevator: Enum.random([true, false]),
      area: Enum.random(1..500),
      score: Enum.random(1..4),
      matterport_code: Faker.String.base64(),
      is_active: true
    }
  end

  def address_factory do
    %Re.Address{
      street: Address.street_name(),
      street_number: Address.building_number(),
      neighborhood: Pokemon.location(),
      city: Address.city(),
      state: Address.state_abbr(),
      postal_code: random_postcode(),
      lat: Address.latitude(),
      lng: Address.longitude()
    }
  end

  def image_factory do
    %Re.Image{
      filename: Internet.image_url(),
      position: Enum.random(-50..50),
      is_active: true
    }
  end

  def featured_listing_factory do
    %Re.Listings.FeaturedListing{
      position: 0
    }
  end

  def interest_type_factory do
    %Re.Listings.InterestType{
      name: "Just looking"
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
  defp random(:price), do: Enum.random(1..999_999_999)
  defp random(:price_float), do: Enum.random(1..999_999_999) / 100

  defp random(:floor) do
    1..50
    |> Enum.random()
    |> Integer.to_string()
  end
end
