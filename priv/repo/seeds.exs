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
alias ReWeb.{Address, Listing}

Repo.delete_all(Listing)
Repo.delete_all(Address)

Repo.insert! %Address{
  street: "Delfim Moreira",
  neighborhood: "Leblon",
  city: "Rio de Janeiro",
  state: "RJ",
  postal_code: "22291-000",
  listings: [
    %Listing{
      name: "First Apartament",
      description: "Wonderful description for the first apartment",
      floor: "3",
      price: 1000000,
      area: 90,
      rooms: 2,
      bathrooms: 1,
      garage_spots: 1
    },
    %Listing{
      name: "Second Apartament",
      description: "Wonderful description for the second apartment",
      floor: "8",
      price: 1845000,
      area: 136,
      rooms: 4,
      bathrooms: 2,
      garage_spots: 2
    }
  ]
}
