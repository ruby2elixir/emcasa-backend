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

alias Re.{Repo, Listing}

Repo.delete_all(Listing)

Repo.insert! %Listing{
  name: "Primeiro Apartamento",
  description: "Descrição maravilhosa do primeiro apartamento"
}

Repo.insert! %Listing{
  name: "Segundo Apartamento",
  description: "Descrição maravilhosa do segundo apartamento"
}
