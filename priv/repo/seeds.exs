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
alias ReWeb.Listing

Repo.delete_all(Listing)

Repo.insert! %Listing{
  name: "First Apartament",
  description: "Wonderful description for the first apartment",
  price: 1000000,
  area: 90,
  rooms: 2
}

Repo.insert! %Listing{
  name: "Second Apartament",
  description: "Wonderful description for the second apartment",
  price: 1845000,
  area: 136,
  rooms: 4
}
