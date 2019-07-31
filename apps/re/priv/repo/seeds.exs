alias Re.{
  Address,
  Calendars.TourAppointment,
  Development,
  Favorite,
  Image,
  Interest,
  Interests.ContactRequest,
  Listing,
  Listings.PriceHistory,
  Listings.StatusHistory,
  ListingTag,
  PriceSuggestions.Request,
  Repo,
  Tag,
  Unit,
  User
}

Repo.delete_all(Image)
Repo.delete_all(Interest)
Repo.delete_all(Favorite)
Repo.delete_all(ListingTag)
Repo.delete_all(PriceHistory)
Repo.delete_all(StatusHistory)
Repo.delete_all(TourAppointment)
Repo.delete_all(Unit)
Repo.delete_all(Listing)
Repo.delete_all(Request)
Repo.delete_all(Address)
Repo.delete_all(ContactRequest)
Repo.delete_all(User)
Repo.delete_all(Development)
Repo.delete_all(Tag)

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
    uuid: UUID.uuid4(),
    type: "Apartamento",
    description: "A description about the listing.",
    floor: "1",
    price: 1_000_000,
    area: 100,
    rooms: 2,
    bathrooms: 2,
    garage_spots: 1,
    liquidity_ratio: 3.0,
    images: [image1],
    user: admin1,
    address: address1,
    status: "active"
  })

Repo.delete_all(Tag)

[
  %{category: "concierge", name: "24 Horas", visibility: "public"},
  %{category: "concierge", name: "Horario Comercial", visibility: "public"},
  %{category: "concierge", name: "Portaria Eletrônica", visibility: "public"},
  %{category: "infrastructure", name: "Academia", visibility: "public"},
  %{category: "infrastructure", name: "Bicicletário", visibility: "public"},
  %{category: "infrastructure", name: "Brinquedoteca", visibility: "public"},
  %{category: "infrastructure", name: "Churrasqueira", visibility: "public"},
  %{category: "infrastructure", name: "Espaço Gourmet", visibility: "public"},
  %{category: "infrastructure", name: "Espaço Verde", visibility: "public"},
  %{category: "infrastructure", name: "Parque", visibility: "public"},
  %{category: "infrastructure", name: "Piscina", visibility: "public"},
  %{category: "infrastructure", name: "Playground", visibility: "public"},
  %{category: "infrastructure", name: "Quadra", visibility: "public"},
  %{category: "infrastructure", name: "Salão De Festas", visibility: "public"},
  %{category: "infrastructure", name: "Salão De Jogos", visibility: "public"},
  %{category: "infrastructure", name: "Sauna", visibility: "public"},
  %{category: "realty", name: "Armários Embutidos", visibility: "public"},
  %{category: "realty", name: "Banheiro Empregados", visibility: "public"},
  %{category: "realty", name: "Bom Para Pets", visibility: "public"},
  %{category: "realty", name: "Dependência Empregados", visibility: "public"},
  %{category: "realty", name: "Espaço Para Churrasco", visibility: "public"},
  %{category: "realty", name: "Fogão Embutido", visibility: "public"},
  %{category: "realty", name: "Lavabo", visibility: "public"},
  %{category: "realty", name: "Reformado", visibility: "public"},
  %{category: "realty", name: "Sacada", visibility: "public"},
  %{category: "realty", name: "Terraço", visibility: "public"},
  %{category: "realty", name: "Varanda Gourmet", visibility: "public"},
  %{category: "realty", name: "Varanda", visibility: "public"},
  %{category: "view", name: "Comunidade", visibility: "private"},
  %{category: "view", name: "Cristo", visibility: "public"},
  %{category: "view", name: "Lagoa", visibility: "public"},
  %{category: "view", name: "Mar", visibility: "public"},
  %{category: "view", name: "Montanhas", visibility: "public"},
  %{category: "view", name: "Parcial Comunidade", visibility: "private"},
  %{category: "view", name: "Parcial Mar", visibility: "public"},
  %{category: "view", name: "Pedras", visibility: "public"},
  %{category: "view", name: "Verde", visibility: "public"},
  %{category: "view", name: "Vizinho", visibility: "private"}
]
|> Enum.each(fn params ->
  %Re.Tag{}
  |> Re.Tag.changeset(params)
  |> Re.Repo.insert()
end)

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
    liquidity_ratio: 4.0,
    images: [image2],
    user: admin2,
    address: address2,
    status: "active"
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
    liquidity_ratio: 4.0,
    images: [image3],
    user: user1,
    address: address3,
    status: "active"
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
    liquidity_ratio: 4.0,
    images: [image4],
    user: user1,
    address: address4,
    status: "active"
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
    liquidity_ratio: 4.0,
    user: user2,
    address: address5,
    status: "inactive"
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
    liquidity_ratio: 4.0,
    user: user2,
    address: address6,
    status: "inactive"
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
    liquidity_ratio: 4.0,
    user: user2,
    address: address1,
    status: "active"
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
    liquidity_ratio: 4.0,
    user: user2,
    address: address2,
    status: "active"
  })

{:ok, development1} =
  Repo.insert(%Development{
    uuid: UUID.uuid4(),
    name: "EmCasa condominium",
    phase: "building",
    builder: "EmCasa",
    description: "I awesome place to live in."
  })

{:ok, listing9} =
  Repo.insert(%Listing{
    type: "Apartamento",
    description: "A description about the listing.",
    floor: "2",
    price: 2_000_000,
    area: 200,
    rooms: 3,
    bathrooms: 3,
    garage_spots: 2,
    liquidity_ratio: 4.0,
    user: user2,
    address: address2,
    development: development1,
    status: "active"
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

{:ok, _} =
  Repo.insert(%Interest{
    name: "Interested Person 1",
    email: "interested1@email.com",
    phone: "123212321",
    message: "Looks like an awesome listing",
    listing: listing2
  })

{:ok, _} =
  Repo.insert(%Interest{
    name: "Interested Person 2",
    email: "interested2@email.com",
    phone: "321232123",
    message: "Looks like an awesome listing",
    listing: listing2
  })

{:ok, _} =
  Repo.insert(%Interest{
    name: "Interested Person 2",
    email: "interested2@email.com",
    phone: "321232123",
    message: "Looks like an awesome listing",
    listing: listing3
  })

{:ok, _} =
  Repo.insert(%Interest{
    name: "Interested Person 3",
    email: "interested3@email.com",
    phone: "432112344321",
    message: "Looks like an awesome listing",
    listing: listing4
  })

{:ok, _} =
  Repo.insert(%Interest{
    name: "Interested Person 3",
    email: "interested3@email.com",
    phone: "432112344321",
    message: "Looks like an awesome listing",
    listing: listing4
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

{:ok, _} =
  Repo.insert(%Unit{
    listing: listing9,
    uuid: UUID.uuid4(),
    price: 500_000,
    property_tax: 1_500.00,
    maintenance_fee: 1_000.00,
    floor: "1",
    rooms: 1,
    bathrooms: 1,
    restrooms: 1,
    area: 100,
    garage_spots: 1,
    garage_type: "contract",
    suites: 0,
    dependencies: 0,
    balconies: 0
  })

{:ok, _} =
  Repo.insert(%Unit{
    listing: listing9,
    uuid: UUID.uuid4(),
    price: 500_000,
    property_tax: 1_500.00,
    maintenance_fee: 1_000.00,
    floor: "1",
    rooms: 1,
    bathrooms: 1,
    restrooms: 1,
    area: 100,
    garage_spots: 1,
    garage_type: "contract",
    suites: 0,
    dependencies: 0,
    balconies: 0
  })
