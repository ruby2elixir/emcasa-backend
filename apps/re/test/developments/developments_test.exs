defmodule Re.DevelopmentsTest do
  use Re.ModelCase

  alias Re.{
    Development,
    Developments
  }

  import Re.Factory

  describe "insert/2" do
    @insert_development_params %{
      name: "Condomínio EmCasa",
      title: "Condomínio EmCasa",
      phase: "building",
      builder: "EmCasa Corp",
      description: "Mi casa es su casa."
    }

    test "should insert a development" do
      address = insert(:address)

      assert {:ok, inserted_development} =
               Developments.insert(@insert_development_params, address)

      assert retrived_development = Repo.get(Development, inserted_development.id)
      assert retrived_development.address_id == address.id
    end
  end
end
