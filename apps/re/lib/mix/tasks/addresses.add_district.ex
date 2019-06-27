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

  def run(_) do
    Mix.Task.run("app.start")

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
