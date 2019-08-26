defmodule ReIntegrations.SalesforceTest do
  use ReIntegrations.ModelCase

  import Mockery

  import Re.CustomAssertion

  import Re.Factory

  alias ReIntegrations.{
    Repo,
    Salesforce
  }

  @event %{
    start: Timex.now(),
    end: Timex.now(),
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

  describe "schedule_tours/1" do
    test "creates a new job to monitor routific request" do
      assert {:ok, _} = Salesforce.schedule_visits(date: Timex.now())
      assert_enqueued_job(Repo.all(Salesforce.JobQueue), "monitor_routific_job")
    end

    test "updates opportunities with invalid input" do
      mock(
        ReIntegrations.TestHTTP,
        :post,
        {:ok,
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
                     "Periodo_Disponibilidade_Tour__c": "y"
                   },
                   {
                     "Id": "0x02",
                     "AccountId": null,
                     "OwnerId": "0x01",
                     "Bairro__c": "Vila Mariana",
                     "Dados_do_Imovel_para_Venda__c": "address 123",
                     "Data_Fixa_para_o_Tour__c": "2019-07-29",
                     "Horario_Fixo_para_o_Tour__c": "20:25:00",
                     "Periodo_Disponibilidade_Tour__c": "Manhã"
                   }
                 ]
               }
           """
         }}
      )

      assert {:ok, _} = Salesforce.schedule_visits(date: Timex.now())
      assert_enqueued_job(Repo.all(Salesforce.JobQueue), "update_opportunity", 2)
    end
  end

  describe "insert_event/1" do
    test "creates a salesforce event" do
      assert {:ok, %{}} = Salesforce.insert_event(@event)
    end
  end

  describe "update_opportunity/2" do
    test "updates a salesforce opportunity" do
      assert {:ok, %{}} = Salesforce.update_opportunity("0x01", %{stage: :visit_scheduled})
    end
  end
end
