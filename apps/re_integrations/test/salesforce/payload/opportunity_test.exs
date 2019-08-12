defmodule ReIntegrations.Salesforce.Payload.OpportunityTest do
  use ReIntegrations.ModelCase

  alias ReIntegrations.Salesforce.Payload

  @payload %{
    "Id" => "0x01",
    "AccountId" => "0x02",
    "OwnerId" => "0x02",
    "Dados_do_Imovel_para_Venda__c" => "address string",
    "Bairro__c" => "neighborhood",
    "Horario_Fixo_para_o_Tour__c" => "20:00:00",
    "Periodo_Disponibilidade_Tour__c" => "Manhã",
    "StageName" => "Confirmação Visita"
  }

  @opportunity %Payload.Opportunity{
    id: "0x01",
    account_id: "0x02",
    owner_id: "0x02",
    stage: :visit_pending,
    address: "address string",
    neighborhood: "neighborhood",
    tour_strict_time: ~T[20:00:00],
    tour_period: :morning
  }

  describe "build/1" do
    test "builds payload struct from salesforce response" do
      assert {:ok, %Payload.Opportunity{} = opportunity} = Payload.Opportunity.build(@payload)
      assert opportunity.id == @payload["Id"]
      assert opportunity.account_id == @payload["AccountId"]
      assert opportunity.owner_id == @payload["OwnerId"]
      assert opportunity.address == @payload["Dados_do_Imovel_para_Venda__c"]
      assert opportunity.neighborhood == @payload["Bairro__c"]
      assert opportunity.tour_strict_time == ~T[20:00:00Z]
      assert opportunity.tour_period == :morning
    end
  end

  describe "visit_start_window/1" do
    test "returns exact time when tour period is strict" do
      assert %{start: ~T[20:00:00Z], end: ~T[21:00:00.000000]} =
               Payload.Opportunity.visit_start_window(%{
                 tour_strict_time: ~T[20:00:00Z],
                 tour_period: :strict
               })
    end

    test "returns time range from tour period" do
      assert %{start: ~T[09:00:00Z], end: ~T[12:00:00Z]} =
               Payload.Opportunity.visit_start_window(%{tour_period: :morning})

      assert %{start: ~T[12:00:00Z], end: ~T[18:00:00Z]} =
               Payload.Opportunity.visit_start_window(%{tour_period: :afternoon})

      assert %{start: ~T[09:00:00Z], end: ~T[18:00:00Z]} =
               Payload.Opportunity.visit_start_window(%{tour_period: :flexible})
    end

    test "returns default time range when not specified" do
      assert %{start: ~T[09:00:00Z], end: ~T[18:00:00Z]} =
               Payload.Opportunity.visit_start_window(%{})
    end
  end

  describe "Jason.Encoder" do
    test "maps schema keys to salesforce columns" do
      assert Map.drop(@payload, ["Id"]) ==
               @opportunity |> Jason.encode!() |> Jason.decode!()
    end

    test "filters nil values" do
      assert Map.drop(@payload, ["Id", "AccountId"]) ==
               @opportunity |> Map.drop([:account_id]) |> Jason.encode!() |> Jason.decode!()
    end
  end
end
