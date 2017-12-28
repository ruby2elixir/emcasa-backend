defmodule Re.Factory do
  @moduledoc """
  Use the factories here in tests.
  """

  use ExMachina.Ecto, repo: Re.Repo

  def user_factory do
    %Re.User {
      email: "user@example.com",
      password: "password"
    }
  end

  def listing_factory do
    %Re.Listing {
      type: "Apartamento",
      complement: "100",
      description: "A description",
      price: 1_000_000,
      floor: "3",
      rooms: 3,
      bathrooms: 2,
      garage_spots: 1,
      area: 100,
      score: 3,
      matterport_code: "",
      is_active: true
    }
  end

  def address_factory do
    %Re.Address {
      street: "Street Name",
      street_number: "99",
      neighborhood: "A neighborhood",
      city: "A City",
      state: "ST",
      postal_code: "12345-678",
      lat: "-25",
      lng: "35"
    }
  end

  def image_factory do
    %Re.Image {
      filename: "image.jpeg",
      position: 5
    }
  end

end
