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
    Mix.EctoSQL.ensure_started(Re.Repo, [])

    {:ok, district} =
      %District{}
      |> District.changeset(%{
        name: "Vila Mariana",
        state: "SP",
        city: "São Paulo",
        status: "active"
      })
      |> Repo.insert()

    Mix.shell().info("Inserted district: #{district.name}, id: #{district.id}")
  end
end
