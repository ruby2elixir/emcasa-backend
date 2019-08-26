defmodule ReIntegrations.SalesforceTest do
  use ReIntegrations.ModelCase
  use Mockery

  import Re.CustomAssertion

  import Re.Factory

  alias ReIntegrations.{
    Repo,
    Salesforce
  }

  @event %{
    start: ~N[2019-08-26 10:00:00],
    end: ~N[2019-08-26 10:00:00],
    duration: 60,
    type: :visit,
    subject: "some subject"
  }

  setup do
    address = insert(:address)
    district = insert(:district, name: "Vila Mariana", name_slug: "vila-mariana")
    insert(:calendar, address: address, districts: [district])
    :ok
  end

  @response {:ok,
             %{
               status_code: 200,
               body: """
               {
                 "records": [
                   {
                     "Id": "0x01",
                     "AccountId": "0x01",
                     "OwnerId": "0x01",
                     "Bairro__c": "Vila Mariana",
                     "Dados_do_Imovel_para_Venda__c": "address 123",
                     "Periodo_Disponibilidade_Tour__c": "Manhã"
                   },
                   {
                     "Id": "0x02",
                     "AccountId": "0x01",
                     "OwnerId": "0x01",
                     "Bairro__c": "Vila Mariana",
                     "Dados_do_Imovel_para_Venda__c": "address 123",
                     "Data_Fixa_para_o_Tour__c": "2019-08-26",
                     "Horario_Fixo_para_o_Tour__c": "20:25:00",
                     "Periodo_Disponibilidade_Tour__c": "Fixo"
                   }
                 ]
               }
               """
             }}

  @soql """
  SELECT Id, AccountId, OwnerId, StageName, Dados_do_Imovel_para_Venda__c, Bairro__c, Comentarios_do_Agendamento__c, Data_Fixa_para_o_Tour__c, Horario_Fixo_para_o_Tour__c, Periodo_Disponibilidade_Tour__c, Motivo_do_nao_agendamento__c, Link_da_rota__c
  FROM Opportunity
  WHERE
    StageName = 'Confirmação Visita' AND
    Periodo_Disponibilidade_Tour__c != 'Proprietário com fotos' AND (
      Data_Fixa_para_o_Tour__c = NULL OR
      Data_Fixa_para_o_Tour__c = 2019-08-26)
  ORDER BY CreatedDate ASC
  """

  describe "schedule_tours/1" do
    test "creates a new job to monitor routific request" do
      mock(HTTPoison, [post: 3], fn
        %URI{path: "/api/v1/query"}, _, _ -> @response
        %URI{path: "/v1/vrp-long"}, _, _ -> {:ok, %{body: ~s({"job_id": "100"})}}
      end)

      assert {:ok, _} = Salesforce.schedule_visits(date: ~N[2019-08-26 00:00:00])

      body = Jason.encode!(%{soql: @soql})

      assert_enqueued_job(Repo.all(Salesforce.JobQueue), "monitor_routific_job")

      assert_called(HTTPoison, :post, [
        %URI{path: "/api/v1/query"},
        ^body,
        [{"Authorization", ""}, {"Content-Type", "application/json"}]
      ])
    end
  end

  describe "insert_event/1" do
    test "creates a salesforce event" do
      mock(HTTPoison, :post, {:ok, %{status_code: 200, body: ~s({"Id":"0x01"})}})
      assert {:ok, %{}} = Salesforce.insert_event(@event)

      body =
        ~s({"Description":null,"DurationInMinutes":60,"EndDateTime":"2019-08-26T10:00:00","Location":null,"OwnerId":null,"StartDateTime":"2019-08-26T10:00:00","Subject":"some subject","Type":"Visita","WhatId":null,"WhoId":null})

      assert_called(HTTPoison, :post, [
        %URI{path: "/api/v1/Event"},
        ^body,
        [{"Authorization", ""}, {"Content-Type", "application/json"}]
      ])
    end
  end

  describe "update_opportunity/2" do
    test "updates a salesforce opportunity" do
      mock(HTTPoison, :patch, {:ok, %{status_code: 200, body: ~s({"Id":"0x01"})}})

      assert {:ok, %{}} = Salesforce.update_opportunity("0x01", %{stage: :visit_scheduled})

      body = ~s({"StageName":"Visita agendada"})

      assert_called(HTTPoison, :patch, [
        %URI{path: "/api/v1/Opportunity/0x01"},
        ^body,
        [{"Authorization", ""}, {"Content-Type", "application/json"}]
      ])
    end
  end
end
