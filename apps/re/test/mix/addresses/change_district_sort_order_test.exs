defmodule Mix.Tasks.Re.Addresses.ChangeDistrictSortOrderTest do
  use Re.ModelCase

  alias Mix.Tasks.Re.Addresses.ChangeDistrictSortOrder

  alias Re.{
    Addresses.District,
    Addresses.Neighborhoods,
    Repo
  }

  setup do
    Mix.shell(Mix.Shell.Process)

    on_exit(fn ->
      Mix.shell(Mix.Shell.IO)
    end)

    :ok
  end

  describe "run/1" do
    test "update district" do
      insert_districts([])
      ChangeDistrictSortOrder.run([])
      sort_order = Enum.map(Neighborhoods.districts(), fn district -> district.sort_order end)
      expected_order = Enum.to_list(1..21)
      assert expected_order == sort_order
    end
  end

  defp insert_districts(_) do
    districts_to_insert = [
      "Perdizes",
      "Pinheiros",
      "Sumarezinho",
      "Vila Mariana",
      "Vila Anglo Brasileira",
      "Sumaré",
      "Cerqueira César",
      "Vila Pompéia",
      "Moema",
      "Aclimação",
      "Bosque da Saúde",
      "Brooklin",
      "Chácara Inglesa",
      "Vila Madalena",
      "Vila Olímpia",
      "Chácara Klabin",
      "Paraíso",
      "Jardim Luzitania",
      "Vila Clementino",
      "Jardim Vila Mariana",
      "Jardim da Gloria"
    ]

    Enum.each(districts_to_insert, fn district_to_insert ->
      %District{}
      |> District.changeset(%{
        name: district_to_insert,
        state: "SP",
        city: "São Paulo",
        status: "covered"
      })
      |> Repo.insert()
    end)
  end
end
