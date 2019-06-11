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

    Logger.info("Inserted district named #{district.name}")
  end

  def insert(params) do
    {:ok, tag} =
      %Re.Tag{}
      |> Re.Tag.changeset(params)
      |> Re.Repo.insert(on_conflict: :nothing)

    Logger.info("insert : tag name #{tag.name_slug}")
  end
end
