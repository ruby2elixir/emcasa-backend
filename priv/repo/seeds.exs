if Mix.env == :dev do

  alias Re.{
    Address,
    Image,
    Listings.Interest,
    Listing,
    Repo,
    User
  }
  alias Comeonin.Bcrypt

  Repo.delete_all(User)
  Repo.delete_all(Image)
  Repo.delete_all(Listing)
  Repo.delete_all(Address)
  Repo.delete_all(Interest)

  {:ok, admin1} = Repo.insert(%User{
    name: "Admin 1",
    email: "admin1@emcasa.com",
    phone: "11111111111",
    password: Bcrypt.hashpwsalt("password"),
    role: "admin"
  })

  {:ok, admin2} = Repo.insert(%User{
    name: "Admin 2",
    email: "admin2@emcasa.com",
    phone: "22222222222",
    password: Bcrypt.hashpwsalt("password"),
    role: "admin"
  })

  {:ok, user1} = Repo.insert(%User{
    name: "User 1",
    email: "user1@emcasa.com",
    phone: "33333333333",
    password: Bcrypt.hashpwsalt("password"),
    role: "user"
  })

  {:ok, user2} = Repo.insert(%User{
    name: "User 2",
    email: "user2@emcasa.com",
    phone: "4444444444",
    password: Bcrypt.hashpwsalt("password"),
    role: "user"
  })

  {:ok, address1} = Repo.insert(%Address{
    street: "Test Street 1",
    street_number: "1",
    neighborhood: "Downtown",
    city: "Test City 1",
    state: "ST",
    postal_code: "11111-111",
    lat: "-10",
    lng: "-10"
  })


  {:ok, address2} = Repo.insert(%Address{
    street: "Test Street 2",
    street_number: "2",
    neighborhood: "Downtown",
    city: "Test City 2",
    state: "ST",
    postal_code: "22222-222",
    lat: "-20",
    lng: "-20"
  })

  {:ok, image1} = Repo.insert(%Image{
    filename: "image1.jpg",
    position: 1
  })

  {:ok, image2} = Repo.insert(%Image{
    filename: "image2.jpg",
    position: 2
  })

  {:ok, image3} = Repo.insert(%Image{
    filename: "image3.jpg",
    position: 3
  })

  {:ok, listing1} = Repo.insert(%Listing{
    type: "Apartment",
    description: "A description about the listing.",
    floor: "1",
    price: 1_000_000,
    area: 100,
    rooms: 2,
    bathrooms: 2,
    garage_spots: 1,
    score: 3,
    images: [image1, image2],
    user: admin1,
    address: address1
  })

  {:ok, listing2} = Repo.insert(%Listing{
    type: "House",
    description: "A description about the listing.",
    floor: "2",
    price: 2_000_000,
    area: 200,
    rooms: 3,
    bathrooms: 3,
    garage_spots: 2,
    score: 4,
    images: [image2, image3],
    user: admin2,
    address: address2
  })


  {:ok, listing3} = Repo.insert(%Listing{
    type: "House",
    description: "A description about the listing.",
    floor: "3",
    price: 3_000_000,
    area: 300,
    rooms: 5,
    bathrooms: 2,
    garage_spots: 1,
    score: 4,
    images: [image1, image3],
    user: user1,
    address: address1
  })


  {:ok, listing4} = Repo.insert(%Listing{
    type: "House",
    description: "A description about the listing.",
    floor: "4",
    price: 4_000_000,
    area: 400,
    rooms: 3,
    bathrooms: 3,
    garage_spots: 2,
    score: 4,
    images: [image2],
    user: user1,
    address: address2
  })


  {:ok, listing5} = Repo.insert(%Listing{
    type: "House",
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

  {:ok, interest1} = Repo.insert(%Interest{
    name: "Interested Person 1",
    email: "interested1@email.com",
    phone: "123212321",
    message: "Looks like an awesome listing",
    listing: listing2
  })

  {:ok, interest2} = Repo.insert(%Interest{
    name: "Interested Person 2",
    email: "interested2@email.com",
    phone: "321232123",
    message: "Looks like an awesome listing",
    listing: listing2
  })

  {:ok, interest3} = Repo.insert(%Interest{
    name: "Interested Person 2",
    email: "interested2@email.com",
    phone: "321232123",
    message: "Looks like an awesome listing",
    listing: listing3
  })

  {:ok, interest4} = Repo.insert(%Interest{
    name: "Interested Person 3",
    email: "interested3@email.com",
    phone: "432112344321",
    message: "Looks like an awesome listing",
    listing: listing4
  })

end
