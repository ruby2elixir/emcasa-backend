if Mix.env() == :dev do
  alias Re.{
    Address,
    Image,
    Listings.Interest,
    Listings.InterestType,
    Listing,
    Repo,
    User
  }

  alias Comeonin.Bcrypt

  Repo.delete_all(Image)
  Repo.delete_all(Interest)
  Repo.delete_all(Listing)
  Repo.delete_all(Address)
  Repo.delete_all(User)

  {:ok, admin1} =
    Repo.insert(%User{
      name: "Admin 1",
      email: "admin1@emcasa.com",
      phone: "11111111111",
      password_hash: Bcrypt.hashpwsalt("password"),
      role: "admin",
      confirmed: true
    })

  {:ok, admin2} =
    Repo.insert(%User{
      name: "Admin 2",
      email: "admin2@emcasa.com",
      phone: "22222222222",
      password_hash: Bcrypt.hashpwsalt("password"),
      role: "admin",
      confirmed: true
    })

  {:ok, user1} =
    Repo.insert(%User{
      name: "User 1",
      email: "user1@emcasa.com",
      phone: "33333333333",
      password_hash: Bcrypt.hashpwsalt("password"),
      role: "user",
      confirmed: true
    })

  {:ok, user2} =
    Repo.insert(%User{
      name: "User 2",
      email: "user2@emcasa.com",
      phone: "4444444444",
      password_hash: Bcrypt.hashpwsalt("password"),
      role: "user",
      confirmed: true
    })

  {:ok, address1} =
    Repo.insert(%Address{
      street: "Test Street 1",
      street_number: "1",
      neighborhood: "Downtown",
      city: "Test City 1",
      state: "ST",
      postal_code: "11111-111",
      lat: -10.101,
      lng: -10.101
    })

  {:ok, address2} =
    Repo.insert(%Address{
      street: "Test Street 2",
      street_number: "2",
      neighborhood: "Downtown",
      city: "Test City 2",
      state: "ST",
      postal_code: "22222-222",
      lat: -20.20202020202,
      lng: -20.20202020202
    })

  {:ok, image1} =
    Repo.insert(%Image{
      filename: "axetblju0i3keovz87ab.jpg",
      position: 1,
      is_active: true
    })

  {:ok, image2} =
    Repo.insert(%Image{
      filename: "cz9ytkthhdmd0f9mt2wy.jpg",
      position: 2,
      is_active: true
    })

  {:ok, image3} =
    Repo.insert(%Image{
      filename: "u6fy4vpnjqff7jjxcg27.jp",
      position: 3,
      is_active: true
    })

  {:ok, image4} =
    Repo.insert(%Image{
      filename: "u6fy4vpnjqff7jjxcg27.jp",
      position: 3,
      is_active: true
    })

  {:ok, listing1} =
    Repo.insert(%Listing{
      type: "Apartamento",
      description: "A description about the listing.",
      floor: "1",
      price: 1_000_000,
      area: 100,
      rooms: 2,
      bathrooms: 2,
      garage_spots: 1,
      score: 3,
      images: [image1],
      user: admin1,
      address: address1
    })

  {:ok, listing2} =
    Repo.insert(%Listing{
      type: "Casa",
      description: "A description about the listing.",
      floor: "2",
      price: 2_000_000,
      area: 200,
      rooms: 3,
      bathrooms: 3,
      garage_spots: 2,
      score: 4,
      images: [image2],
      user: admin2,
      address: address2
    })

  {:ok, listing3} =
    Repo.insert(%Listing{
      type: "Casa",
      description: "A description about the listing.",
      floor: "3",
      price: 3_000_000,
      area: 300,
      rooms: 5,
      bathrooms: 2,
      garage_spots: 1,
      score: 4,
      images: [image3],
      user: user1,
      address: address1
    })

  {:ok, listing4} =
    Repo.insert(%Listing{
      type: "Casa",
      description: "A description about the listing.",
      floor: "4",
      price: 4_000_000,
      area: 400,
      rooms: 3,
      bathrooms: 3,
      garage_spots: 2,
      score: 4,
      images: [image4],
      user: user1,
      address: address2
    })

  {:ok, listing5} =
    Repo.insert(%Listing{
      type: "Cobertura",
      description: "A description about the listing.",
      floor: "2",
      price: 2_000_000,
      area: 200,
      rooms: 3,
      bathrooms: 3,
      garage_spots: 2,
      score: 4,
      user: user2,
      address: address2
    })

  {:ok, listing6} =
    Repo.insert(%Listing{
      type: "Cobertura",
      description: "A description about the listing.",
      floor: "2",
      price: 2_000_000,
      area: 200,
      rooms: 3,
      bathrooms: 3,
      garage_spots: 2,
      score: 4,
      user: user2,
      address: address2,
      is_active: false
    })

  {:ok, interest1} =
    Repo.insert(%Interest{
      name: "Interested Person 1",
      email: "interested1@email.com",
      phone: "123212321",
      message: "Looks like an awesome listing",
      listing: listing2
    })

  {:ok, interest2} =
    Repo.insert(%Interest{
      name: "Interested Person 2",
      email: "interested2@email.com",
      phone: "321232123",
      message: "Looks like an awesome listing",
      listing: listing2
    })

  {:ok, interest3} =
    Repo.insert(%Interest{
      name: "Interested Person 2",
      email: "interested2@email.com",
      phone: "321232123",
      message: "Looks like an awesome listing",
      listing: listing3
    })

  {:ok, interest4} =
    Repo.insert(%Interest{
      name: "Interested Person 3",
      email: "interested3@email.com",
      phone: "432112344321",
      message: "Looks like an awesome listing",
      listing: listing4
    })

  Re.Repo.insert!(%InterestType{name: "Me ligue dentro de 5 minutos"})
  Re.Repo.insert!(%InterestType{name: "Me ligue em um horário específico"})
  Re.Repo.insert!(%InterestType{name: "Agendamento por e-mail"})
  Re.Repo.insert!(%InterestType{name: "Agendamento por Whatsapp"})
end
