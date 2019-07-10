defmodule Mix.Tasks.Re.Addresses.ChangeDistrictSortOrder do
  @moduledoc """
  Change the district sort order.
  """
  use Mix.Task

  require Logger

  alias Re.{
    Addresses.District,
    Repo
  }

  @shortdoc "Change the district sort order"

  @districts_sort_order [
    %{name_slug: "perdizes", sort_order: 1},
    %{name_slug: "pinheiros", sort_order: 2},
    %{name_slug: "sumare", sort_order: 3},
    %{name_slug: "sumarezinho", sort_order: 4},
    %{name_slug: "vila-anglo-brasileira", sort_order: 5},
    %{name_slug: "vila-pompeia", sort_order: 6},
    %{name_slug: "vila-mariana", sort_order: 7},
    %{name_slug: "paraiso", sort_order: 8},
    %{name_slug: "jardim-luzitania", sort_order: 9},
    %{name_slug: "vila-clementino", sort_order: 10},
    %{name_slug: "jardim-vila-mariana", sort_order: 11},
    %{name_slug: "jardim-da-gloria", sort_order: 12},
    %{name_slug: "chacara-klabin", sort_order: 13},
    %{name_slug: "moema", sort_order: 14},
    %{name_slug: "aclimacao", sort_order: 15},
    %{name_slug: "bosque-da-saude", sort_order: 16},
    %{name_slug: "vila-olimpia", sort_order: 17},
    %{name_slug: "brooklin", sort_order: 18},
    %{name_slug: "cerqueira-cesar", sort_order: 19},
    %{name_slug: "chacara-inglesa", sort_order: 20},
    %{name_slug: "vila-madalena", sort_order: 21}
  ]

  def run(_) do
    Mix.Task.run("app.start")

    Enum.each(@districts_sort_order, fn %{name_slug: name_slug, sort_order: sort_order} ->
      district =
        District
        |> Repo.get_by(name_slug: name_slug)
        |> District.changeset(%{
          sort_order: sort_order
        })
        |> Repo.update!(force: true)

      Mix.shell().info(
        "Updated district: #{district.name}, id: #{district.id}, sort_order: #{
          district.sort_order
        }"
      )
    end)
  end
end
