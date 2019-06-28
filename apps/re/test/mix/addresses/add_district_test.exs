defmodule Mix.Tasks.Re.Addresses.AddDistrictTest do
  use Re.ModelCase

  alias Mix.Tasks.Re.Addresses.AddDistrict

  alias Re.{
    Addresses.District,
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
    test "inserts district" do
      AddDistrict.run([])

      partially_covered_districts = [
        "Aclimação",
        "Bosque da Saúde",
        "Brooklin",
        "Cerqueira César",
        "Chácara Inglesa",
        "Chácara Klabin",
        "Paraíso",
        "Pompeia",
        "Vila Clementino",
        "Vila Madalena",
        "Vila Olímpia"
      ]

      Enum.each partially_covered_districts, fn district ->
        assert Repo.get_by(District, name: district)
      end
    end
  end
end
