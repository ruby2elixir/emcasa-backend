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
      phase: "building",
      builder: "EmCasa Corp",
      description: "Mi casa es su casa."
    }

    test "should insert a development" do
      address = insert(:address)

      assert {:ok, inserted_development} =
               Developments.insert(@insert_development_params, address)

      assert retrived_development = Repo.get(Development, inserted_development.uuid)
      assert retrived_development.address_id == address.id
    end
  end

  describe "update/3" do
    test "should update development with new params" do
      address = insert(:address)
      development = insert(:development, address: address)

      new_development_params = params_for(:development)
      new_address = insert(:address)

      Developments.update(development, new_development_params, new_address)

      updated_development = Repo.get(Development, development.uuid)
      assert updated_development.address_id == new_address.id
      assert updated_development.name == Map.get(new_development_params, :name)
      assert updated_development.builder == Map.get(new_development_params, :builder)
      assert updated_development.description == Map.get(new_development_params, :description)
      assert updated_development.phase == Map.get(new_development_params, :phase)
    end
  end
end
