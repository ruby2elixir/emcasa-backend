defmodule Mix.Tasks.Re.Addresses.AddDistrict do
  @moduledoc """
  Create a new district.
  """
  use Mix.Task

  require Logger

  alias Re.{
    Addresses.District,
    Repo
  }

  @shortdoc "Create new district"
  @covered_districts [
    "Água Branca",
    "Barra Funda",
    "Pacaembu",
    "Santa Cecília",
    "Vila Buarque",
    "Higienópolis",
    "Consolação",
    "Bela Vista",
    "Liberdade",
    "Aclimação",
    "Vila Romana"
  ]

  def run(_) do
    Mix.Task.run("app.start")

    Enum.each(@covered_districts, fn district_to_insert ->
      {:ok, district} =
        %District{}
        |> District.changeset(%{
          name: district_to_insert,
          state: "SP",
          city: "São Paulo",
          status: "covered"
        })
        |> Repo.insert()

      Mix.shell().info("Inserted district: #{district.name}, id: #{district.id}")
    end)
  end
end
