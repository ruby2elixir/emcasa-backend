defmodule ReIntegrations.Salesforce.Payload.OpportunityTest do
  use ReIntegrations.ModelCase

  alias ReIntegrations.Salesforce.Payload

  @payload %{
    "Id" => "0x01",
    "AccountId" => "0x02",
    "OwnerId" => "0x02",
    "Dados_do_Imovel_para_Venda__c" => "address string",
    "Bairro__c" => "neighborhood",
    "Data_Tour__c" => "2019-07-29T20:00:00.000Z",
    "Faixa_Hor_ria_Tour__c" => "Manhã: 09h - 12h"
  }

  describe "build/1" do
    test "builds payload struct from salesforce response" do
      assert {:ok, %Payload.Opportunity{} = opportunity} = Payload.Opportunity.build(@payload)
      assert opportunity.id == @payload["Id"]
      assert opportunity.account_id == @payload["AccountId"]
      assert opportunity.owner_id == @payload["OwnerId"]
      assert opportunity.address == @payload["Dados_do_Imovel_para_Venda__c"]
      assert opportunity.neighborhood == @payload["Bairro__c"]
      assert opportunity.tour_date == ~N[2019-07-29 20:00:00Z]
      assert opportunity.tour_period == :morning
    end
  end

  describe "visitation_period/1" do
    test "returns exact time when a strict datetime is specified" do
      assert %{start: ~T[20:00:00Z], end: ~T[20:00:00Z]} =
               Payload.Opportunity.visitation_period(%{
                 tour_date: ~N[2019-07-29 20:00:00Z],
                 tour_period: :afternoon
               })
    end

    test "returns time range from opportunity's tour_period" do
      assert %{start: ~T[12:00:00Z], end: ~T[18:00:00Z]} =
               Payload.Opportunity.visitation_period(%{tour_period: :afternoon})
    end

    test "returns default time range when not specified" do
      assert %{start: ~T[09:00:00Z], end: ~T[18:00:00Z]} =
               Payload.Opportunity.visitation_period(%{})
    end
  end
end
