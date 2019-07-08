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
  @partially_covered_districts [
    "Aclimação",
    "Bosque da Saúde",
    "Brooklin",
    "Cerqueira César",
    "Chácara Inglesa",
    "Vila Madalena",
    "Vila Olímpia"
  ]

  def run(_) do
    Mix.Task.run("app.start")

    Enum.each(@partially_covered_districts, fn district_to_insert ->
      {:ok, district} =
        %District{}
        |> District.changeset(%{
          name: district_to_insert,
          state: "SP",
          city: "São Paulo",
          status: "partially_covered"
        })
        |> Repo.insert()

      Mix.shell().info("Inserted district: #{district.name}, id: #{district.id}")
    end)
  end
end
