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

Repo.insert! %Address{
  street: "Rua General Cristóvão Barcelos",
  street_number: "25",
  neighborhood: "Laranjeiras",
  city: "Rio de Janeiro",
  state: "RJ",
  postal_code: "22245-110",
  lat: "-22.940907",
  lng: "-43.19132289999999",
  listings: [
    %Listing{
      type: "Apartamento",
      name: "Apartamento",
      description: "Apartamento em prédio novo (7 anos) com piscina, spa, salão de festa e academia, dois quartos (1 suíte), sala em dois ambientes com varanda banheiro de empregada, 1 vaga na escritura.",
      floor: "3",
      price: 850_000,
      area: 75,
      rooms: 2,
      bathrooms: 2,
      garage_spots: 1,
      score: 4,
      images: [
        %Image{
          filename: "cristovao-barcelos/principal.jpg",
          position: 1
        }
      ]
    }
  ]
}

Repo.insert! %Address{
  street: "Rua Gago Coutinho",
  street_number: "66",
  neighborhood: "Laranjeiras",
  city: "Rio de Janeiro",
  state: "RJ",
  postal_code: "22221-070",
  lat: "-22.9315194",
  lng: "-43.1819802",
  listings: [
    %Listing{
      type: "Apartamento",
      name: "Apartamento",
      description: "Apartamento duplex todo reformado e com decoração impecável, vista livre para o Parque Guinle, próximo à estação do Metrô do Largo do Machado.",
      floor: "7",
      price: 4_750_000,
      area: 280,
      rooms: 4,
      bathrooms: 2,
      garage_spots: 1,
      score: 2,
      images: [
        %Image{
          filename: "gago-coutinho/principal.jpg",
          position: 1
        },
        %Image{
          filename: "gago-coutinho/61.jpg",
          position: 2
        },
        %Image{
          filename: "gago-coutinho/59.jpg",
          position: 3
        },
        %Image{
          filename: "gago-coutinho/56.jpg",
          position: 4
        },
        %Image{
          filename: "gago-coutinho/54.jpg",
          position: 5
        },
        %Image{
          filename: "gago-coutinho/53.jpg",
          position: 6
        },
        %Image{
          filename: "gago-coutinho/48.jpg",
          position: 7
        },
        %Image{
          filename: "gago-coutinho/42.jpg",
          position: 8
        },
        %Image{
          filename: "gago-coutinho/40.jpg",
          position: 9
        },
        %Image{
          filename: "gago-coutinho/36.jpg",
          position: 10
        }
      ]
    }
  ]
}

Repo.insert!(%Image{listing_id: 8, position: 1, filename: "barao-da-torre/principal.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 2, filename: "barao-da-torre/32.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 3, filename: "barao-da-torre/33.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 4, filename: "barao-da-torre/34.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 5, filename: "barao-da-torre/35.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 6, filename: "barao-da-torre/36.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 7, filename: "barao-da-torre/37.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 8, filename: "barao-da-torre/40.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 9, filename: "barao-da-torre/41.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 10, filename: "barao-da-torre/42.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 11, filename: "barao-da-torre/44.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 12, filename: "barao-da-torre/45.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 13, filename: "barao-da-torre/46.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 14, filename: "barao-da-torre/47.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 15, filename: "barao-da-torre/50.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 16, filename: "barao-da-torre/52.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 17, filename: "barao-da-torre/54.jpg"})
Repo.insert!(%Image{listing_id: 8, position: 18, filename: "barao-da-torre/56.jpg"})

