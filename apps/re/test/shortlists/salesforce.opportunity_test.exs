defmodule Re.Shortlists.Salesforce.OpportunityTest do
  use Re.ModelCase

  alias Re.Shortlists.Salesforce.Opportunity

  @payload %{
    "Infraestrutura__c" => "Indiferente",
    "Tipo_do_Imovel__c" => "Apartamento",
    "Quantidade_Minima_de_Quartos__c" => "1",
    "Quantidade_MInima_de_SuItes__c" => "1",
    "Quantidade_Minima_de_Banheiros__c" => "1",
    "Andar_de_Preferencia__c" => "Alto",
    "Necessita_Elevador__c" => "Indiferente",
    "Area_Desejada__c" => "A partir de 60m²",
    "Proximidade_de_Metr__c" => "Sim",
    "Numero_Minimo_de_Vagas__c" => "1",
    "Bairros_de_Interesse__c" => "Botafogo",
    "Valor_M_ximo_para_Compra_2__c" => "De R$750.000 a R$1.000.000",
    "Valor_M_ximo_de_Condom_nio__c" => "R$800 a R$1.000",
    "Portaria_2__c" => "Indiferente"
  }

  describe "build/1" do
    test "builds payload struct from salesforce response" do
      assert {:ok, %Opportunity{} = opportunity} = Opportunity.build(@payload)
      assert opportunity.infra == @payload["Infraestrutura__c"]
      assert opportunity.type == @payload["Tipo_do_Imovel__c"]
      assert opportunity.rooms == @payload["Quantidade_Minima_de_Quartos__c"]
      assert opportunity.suites == @payload["Quantidade_MInima_de_SuItes__c"]
      assert opportunity.bathrooms == @payload["Quantidade_Minima_de_Banheiros__c"]
      assert opportunity.floor == @payload["Andar_de_Preferencia__c"]
      assert opportunity.elevators == @payload["Necessita_Elevador__c"]
      assert opportunity.area == @payload["Area_Desejada__c"]
      assert opportunity.subway == @payload["Proximidade_de_Metr__c"]
      assert opportunity.garage_spots == @payload["Numero_Minimo_de_Vagas__c"]
      assert opportunity.neighborhood == @payload["Bairros_de_Interesse__c"]
      assert opportunity.price == @payload["Valor_M_ximo_para_Compra_2__c"]
      assert opportunity.maintenance_fee == @payload["Valor_M_ximo_de_Condom_nio__c"]
      assert opportunity.lobby == @payload["Portaria_2__c"]
    end
  end
end
