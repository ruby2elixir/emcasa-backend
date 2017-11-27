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
alias ReWeb.{ListingUser, User, Address, Listing, Image}

Repo.delete_all(ListingUser)
Repo.delete_all(User)
Repo.delete_all(Image)
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
  street: "Rua Paula Freitas",
  street_number: "21",
  neighborhood: "Copacabana",
  city: "Rio de Janeiro",
  state: "RJ",
  postal_code: "22040-010",
  lat: "-22.9682784",
  lng: "-43.18275790000001",
  listings: [
    %Listing{
      type: "Apartamento",
      name: "Apartamento",
      description: "Apartamento localizado na quadra da praia com vista incrível (8 minutos a pé até o metrô). Todos os ambientes estão reformados e com ar-condicionado split. Excelente para famílias grandes.",
      floor: "10",
      price: 3_200_000,
      area: 303,
      rooms: 4,
      bathrooms: 5,
      garage_spots: 1,
      score: 3,
      images: [
        %Image{
          filename: "paula-freitas/paula-freitas-0.jpg",
          position: 1
        },
        %Image{
          filename: "paula-freitas/paula-freitas-42.jpg",
          position: 2
        },
        %Image{
          filename: "paula-freitas/paula-freitas-50.jpg",
          position: 3
        },
        %Image{
          filename: "paula-freitas/paula-freitas-53.jpg",
          position: 4
        },
        %Image{
          filename: "paula-freitas/paula-freitas-54.jpg",
          position: 5
        },
        %Image{
          filename: "paula-freitas/paula-freitas-59.jpg",
          position: 6
        },
        %Image{
          filename: "paula-freitas/paula-freitas-60.jpg",
          position: 7
        },
        %Image{
          filename: "paula-freitas/paula-freitas-66.jpg",
          position: 8
        },
        %Image{
          filename: "paula-freitas/paula-freitas-69.jpg",
          position: 9
        },
        %Image{
          filename: "paula-freitas/paula-freitas-72.jpg",
          position: 10
        },
        %Image{
          filename: "paula-freitas/paula-freitas-73.jpg",
          position: 11
        },
        %Image{
          filename: "paula-freitas/paula-freitas-77.jpg",
          position: 12
        },
        %Image{
          filename: "paula-freitas/paula-freitas-81.jpg",
          position: 13
        },
        %Image{
          filename: "paula-freitas/paula-freitas-82.jpg",
          position: 14
        },
        %Image{
          filename: "paula-freitas/paula-freitas-86.jpg",
          position: 15
        },
        %Image{
          filename: "paula-freitas/paula-freitas-90.jpg",
          position: 16
        },
        %Image{
          filename: "paula-freitas/paula-freitas-92.jpg",
          position: 17
        },
        %Image{
          filename: "paula-freitas/paula-freitas-95.jpg",
          position: 18
        },
        %Image{
          filename: "paula-freitas/paula-freitas-96.jpg",
          position: 19
        },
        %Image{
          filename: "paula-freitas/paula-freitas-97.jpg",
          position: 20
        }
      ]
    }
  ]
}
