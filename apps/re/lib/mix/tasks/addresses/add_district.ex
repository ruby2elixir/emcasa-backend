defmodule Mix.Tasks.Re.Addresses.AddDistrict do
  @moduledoc """
  Create a new district.
  """
  use Mix.Task

  require Logger

  def run(_) do
    Mix.EctoSQL.ensure_started(Re.Repo, [])

    {:ok, district} =
      %Re.Addresses.District{}
      |> Re.Addresses.District.changeset(%{
        name: "Vila Mariana",
        state: "SP",
        city: "São Paulo",
        status: "active"
      })
      |> Re.Repo.insert()

    Mix.shell().info("Inserted district: #{district.name}, id: #{district.id}")
  end
end
