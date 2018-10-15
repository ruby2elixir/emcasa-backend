alias Re.{
  Address,
  Favorite,
  Image,
  Interest,
  InterestType,
  Listing,
  Listings.PriceHistory,
  Message,
  Messages.Channels.Channel,
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
    role: "admin"
  })

{:ok, admin2} =
  Repo.insert(%User{
    name: "Admin 2",
    email: "admin2@emcasa.com",
    phone: "22222222222",
    role: "admin"
  })

{:ok, user1} =
  Repo.insert(%User{
    name: "User 1",
    email: "user1@emcasa.com",
    phone: "111111111",
    role: "user"
  })

{:ok, user2} =
  Repo.insert(%User{
    name: "User 2",
    email: "user2@emcasa.com",
    phone: "222222222",
    role: "user"
  })

{:ok, user3} =
  Repo.insert(%User{
    name: "User 3",
    email: "user3@emcasa.com",
    phone: "333333333",
    role: "user"
  })

{:ok, user4} =
  Repo.insert(%User{
    name: "User 4",
    email: "user4@emcasa.com",
    phone: "4444444444",
    role: "user"
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

{:ok, address3} =
  Repo.insert(%Address{
    street: "Test Street 3",
    street_number: "3",
    neighborhood: "Downtown",
    city: "Test City 3",
    state: "ST",
    postal_code: "33333-333",
    lat: -15.101,
    lng: -5.101
  })

{:ok, address4} =
  Repo.insert(%Address{
    street: "Test Street 4",
    street_number: "4",
    neighborhood: "Downtown",
    city: "Test City 4",
    state: "ST",
    postal_code: "44444-444",
    lat: -25.20202020202,
    lng: -15.20202020202
  })

{:ok, address5} =
  Repo.insert(%Address{
    street: "Test Street 5",
    street_number: "5",
    neighborhood: "Downtown",
    city: "Test City 5",
    state: "ST",
    postal_code: "55555-555",
    lat: -35.101,
    lng: -25.101
  })

{:ok, address6} =
  Repo.insert(%Address{
    street: "Test Street 6",
    street_number: "6",
    neighborhood: "Downtown",
    city: "Test City 6",
    state: "ST",
    postal_code: "66666-666",
    lat: -45.20202020202,
    lng: -35.20202020202
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
    address: address3
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
    address: address4
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
    address: address5
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
    address: address6,
    is_active: false
  })

{:ok, listing7} =
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
    user: user2,
    address: address1,
    is_active: true
  })

{:ok, listing8} =
  Repo.insert(%Listing{
    type: "Apartamento",
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
    is_active: true
  })

{:ok, _} =
  Repo.insert(%PriceHistory{
      price: 1_900_000,
      listing: listing1
    })

{:ok, _} =
  Repo.insert(%PriceHistory{
      price: 2_100_000,
      listing: listing1
    })

{:ok, _} =
  Repo.insert(%PriceHistory{
      price: 1_900_000,
      listing: listing2
    })

{:ok, _} =
  Repo.insert(%PriceHistory{
      price: 1_900_000,
      listing: listing3
    })

{:ok, interest_type1} = Re.Repo.insert(%InterestType{name: "Me ligue dentro de 5 minutos"})
{:ok, interest_type2} = Re.Repo.insert(%InterestType{name: "Me ligue em um horário específico"})
{:ok, interest_type3} = Re.Repo.insert(%InterestType{name: "Agendamento por e-mail"})
{:ok, interest_type4} = Re.Repo.insert(%InterestType{name: "Agendamento por Whatsapp"})
{:ok, interest_type5} = Re.Repo.insert(%InterestType{name: "Agendamento online"})

{:ok, _} =
  Repo.insert(%Interest{
    name: "Interested Person 1",
    email: "interested1@email.com",
    phone: "123212321",
    message: "Looks like an awesome listing",
    listing: listing2,
    interest_type: interest_type1
  })

{:ok, _} =
  Repo.insert(%Interest{
    name: "Interested Person 2",
    email: "interested2@email.com",
    phone: "321232123",
    message: "Looks like an awesome listing",
    listing: listing2,
    interest_type: interest_type2
  })

{:ok, _} =
  Repo.insert(%Interest{
    name: "Interested Person 2",
    email: "interested2@email.com",
    phone: "321232123",
    message: "Looks like an awesome listing",
    listing: listing3,
    interest_type: interest_type3
  })

{:ok, _} =
  Repo.insert(%Interest{
    name: "Interested Person 3",
    email: "interested3@email.com",
    phone: "432112344321",
    message: "Looks like an awesome listing",
    listing: listing4,
    interest_type: interest_type4
  })

{:ok, _} =
  Repo.insert(%Interest{
    name: "Interested Person 3",
    email: "interested3@email.com",
    phone: "432112344321",
    message: "Looks like an awesome listing",
    listing: listing4,
    interest_type: interest_type5
  })

{:ok, _} =
  Repo.insert(%Favorite{
    user: user1,
    listing: listing2
  })

{:ok, _} =
  Repo.insert(%Favorite{
    user: user2,
    listing: listing2
  })

{:ok, _} =
  Repo.insert(%Favorite{
    user: user3,
    listing: listing3
  })

{:ok, _} =
  Repo.insert(%Favorite{
    user: user4,
    listing: listing4
  })

{:ok, _} =
  Repo.insert(%Favorite{
    user: user1,
    listing: listing5
  })

{:ok, _} =
  Repo.insert(%Favorite{
    user: user2,
    listing: listing6
  })

{:ok, _} =
  Repo.insert(%Favorite{
    user: user3,
    listing: listing7
  })

{:ok, _} =
  Repo.insert(%Favorite{
    user: user4,
    listing: listing8
  })

{:ok, channel1} =
  Repo.insert(%Channel{
    participant1: user1,
    participant2: admin1,
    listing: listing1
  })

{:ok, _} =
  Repo.insert(%Message{
    message: "msg11",
    notified: true,
    read: false,
    sender: user1,
    receiver: admin1,
    listing: listing1,
    channel: channel1
  })

{:ok, _} =
  Repo.insert(%Message{
    message: "msg12",
    notified: false,
    read: true,
    sender: user1,
    receiver: admin1,
    listing: listing1,
    channel: channel1
  })

{:ok, _} =
  Repo.insert(%Message{
    message: "msg12",
    notified: false,
    read: true,
    sender: admin1,
    receiver: user1,
    listing: listing1,
    channel: channel1
  })

{:ok, channel2} =
  Repo.insert(%Channel{
    participant1: user2,
    participant2: admin2,
    listing: listing2
  })

{:ok, _} =
  Repo.insert(%Message{
    message: "msg21",
    notified: true,
    read: false,
    sender: user2,
    receiver: admin2,
    listing: listing2,
    channel: channel1
  })

{:ok, _} =
  Repo.insert(%Message{
    message: "msg22",
    notified: false,
    read: true,
    sender: user2,
    receiver: admin2,
    listing: listing2,
    channel: channel2
  })

{:ok, _} =
  Repo.insert(%Message{
    message: "msg22",
    notified: false,
    read: true,
    sender: admin2,
    receiver: user2,
    listing: listing2,
    channel: channel2
  })

