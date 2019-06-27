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

  def run(_) do
    Mix.Ecto.ensure_repo(Re.Repo, [])

    {:ok, district} =
      %District{}
      |> District.changeset(%{
        name: "Vila Mariana",
        state: "SP",
        city: "São Paulo",
        status: "covered"
      })
      |> Repo.insert()

    Mix.shell().info("Inserted district: #{district.name}, id: #{district.id}")

    {:ok, district} =
      %District{}
      |> District.changeset(%{
        name: "Moema",
        state: "SP",
        city: "São Paulo",
        status: "partially_covered"
      })
      |> Repo.insert()

    Mix.shell().info("Inserted district: #{district.name}, id: #{district.id}")
  end
end
