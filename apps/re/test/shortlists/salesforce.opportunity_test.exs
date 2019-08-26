defmodule Re.Shortlists.Salesforce.OpportunityTest do
  use Re.ModelCase

  alias Re.Shortlists.Salesforce.Opportunity

  @payload %{
    "Infraestrutura__c" => "Indiferente;Sacada;Churrasqueira",
    "Tipo_do_Imovel__c" => "Apartamento",
    "Quantidade_Minima_de_Quartos__c" => "1",
    "Quantidade_MInima_de_SuItes__c" => "1",
    "Quantidade_Minima_de_Banheiros__c" => "1",
    "Numero_Minimo_de_Vagas__c" => "1",
    "Area_Desejada__c" => "A partir de 60m²",
    "Andar_de_Preferencia__c" => "Alto",
    "Necessita_Elevador__c" => "Indiferente",
    "Proximidade_de_Metr__c" => "Sim",
    "Bairros_de_Interesse__c" => "Botafogo;Urca",
    "Valor_M_ximo_para_Compra_2__c" => "De R$750.000 a R$1.000.000",
    "Valor_M_ximo_de_Condom_nio__c" => "R$800 a R$1.000",
    "Portaria_2__c" => "Portaria Eletrônica",
    "AccountName" => "Vanessa",
    "OwnerName" => "Pablo"
  }

  describe "build/1" do
    @tag dev: true
    test "builds payload struct from salesforce response" do
      assert {:ok, %Opportunity{} = opportunity} = Opportunity.build(@payload)
      assert opportunity.infrastructure == ["sacada", "churrasqueira"]
      assert opportunity.type == "apartamento"

      assert opportunity.min_rooms ==
               @payload["Quantidade_Minima_de_Quartos__c"] |> String.to_integer()

      assert opportunity.min_suites ==
               @payload["Quantidade_MInima_de_SuItes__c"] |> String.to_integer()

      assert opportunity.min_bathrooms ==
               @payload["Quantidade_Minima_de_Banheiros__c"] |> String.to_integer()

      assert opportunity.min_garage_spots ==
               @payload["Numero_Minimo_de_Vagas__c"] |> String.to_integer()

      assert opportunity.min_area == 60
      assert opportunity.preference_floor == :high
      assert opportunity.elevators == nil
      assert opportunity.nearby_subway == true
      assert opportunity.neighborhoods == ["botafogo", "urca"]
      assert opportunity.price_range == [750_000, 1_000_000]
      assert opportunity.maintenance_fee_range == [800, 1_000]
      assert opportunity.lobby == "portaria-eletronica"
      assert opportunity.user_name == "Vanessa"
      assert opportunity.owner_name == "Pablo"
    end
  end
end
