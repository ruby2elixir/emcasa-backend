# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Re.Repo.insert!(%Re.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Re.Repo
alias ReWeb.{User, Address, Listing}

Repo.delete_all(User)
Repo.delete_all(Listing)
Repo.delete_all(Address)

Repo.insert! %User {
  name: "Gustavo Rocha Saiani",
  email: "gustavo.saiani@emcasa.com",
  phone: "+55 21 9 9962 2634"
}

Repo.insert! %User {
  name: "Gustavo Vaz",
  email: "gustavo.vaz@emcasa.com",
  phone: "+55 21 9 8123 2634"
}

Repo.insert! %User {
  name: "Lucas Cardozo",
  email: "lucas.cardozo@emcasa.com",
  phone: "+55 21 9 9542 9672"
}

Repo.insert! %Address{
  street: "Rua Jardim Botânico",
  street_number: "171",
  neighborhood: "Jardim Botânico",
  city: "Rio de Janeiro",
  state: "RJ",
  postal_code: "22470-050",
  lat: "-22.9608099",
  lng: "-43.2096142",
  listings: [
    %Listing{
      name: "Apartamento",
      description: "2 Quartos no ponto mais nobre do Jardim Botânico",
      floor: "1",
      price: 1150000,
      area: 75,
      rooms: 2,
      bathrooms: 2,
      garage_spots: 2,
      photo: "listing_1.jpg"
    }
  ]
}

Repo.insert! %Address{
  street: "Rua Barão da Torre",
  street_number: "571",
  neighborhood: "Ipanema",
  city: "Rio de Janeiro",
  state: "RJ",
  postal_code: "22411-000",
  lat: "-22.9773729",
  lng: "-43.2309144",
  listings: [
    %Listing{
      name: "Apartamento",
      description: "Apartamento amplo em ótimo estado com 3 quartos (1 suíte) próximo dos melhores restaurantes do bairro. A 5 minutos da praia (posto 10) e a 8 minutos do metrô.",
      floor: "2",
      price: 2_400_000,
      area: 144,
      rooms: 3,
      bathrooms: 3,
      garage_spots: 1,
      photo: "barao-da-torre.jpg"
    }
  ]
}
