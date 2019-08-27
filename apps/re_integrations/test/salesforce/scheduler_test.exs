defmodule ReIntegrations.Salesforce.SchedulerTest do
  use ReIntegrations.ModelCase
  use Mockery

  import Re.CustomAssertion
  import Re.Factory

  alias ReIntegrations.Salesforce

  @thursday ~N[2019-08-29 00:00:00] |> Timex.to_datetime()
  @friday ~N[2019-08-30 00:00:00] |> Timex.to_datetime()
  @saturday ~N[2019-08-31 00:00:00] |> Timex.to_datetime()
  @sunday ~N[2019-09-01 00:00:00] |> Timex.to_datetime()

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
                     "Cidade__c": "São Paulo",
                     "Dados_do_Imovel_para_Venda__c": "address 123",
                     "Periodo_Disponibilidade_Tour__c": "Manhã"
                   },
                   {
                     "Id": "0x02",
                     "AccountId": "0x01",
                     "OwnerId": "0x01",
                     "Cidade__c": "São Paulo",
                     "Dados_do_Imovel_para_Venda__c": "address 123",
                     "Data_Fixa_para_o_Tour__c": "2019-08-26",
                     "Horario_Fixo_para_o_Tour__c": "20:25:00",
                     "Periodo_Disponibilidade_Tour__c": "Fixo"
                   }
                 ]
               }
               """
             }}

  setup do
    address = insert(:address)
    insert(:calendar, address: address)

    mock(HTTPoison, [post: 3], fn
      %URI{path: "/api/v1/query"}, _, _ -> @response
      %URI{path: "/v1/vrp-long"}, _, _ -> {:ok, %{body: ~s({"job_id": "100"})}}
    end)

    :ok
  end

  describe "schedule_daily_visits/1" do
    test "creates a new job to monitor routific request" do
      Salesforce.Scheduler.schedule_daily_visits(@thursday)

      assert_enqueued_job(Repo.all(Salesforce.JobQueue), "monitor_routific_job")
    end

    test "creates two jobs to monitor routific requests on fridays" do
      Salesforce.Scheduler.schedule_daily_visits(@friday)
      assert_enqueued_job(Repo.all(Salesforce.JobQueue), "monitor_routific_job", 2)
    end

    test "doesn't run on saturdays and sundays" do
      assert [] ==
               Salesforce.Scheduler.schedule_daily_visits(@saturday)

      assert [] ==
               Salesforce.Scheduler.schedule_daily_visits(@sunday)

      assert_enqueued_job(Repo.all(Salesforce.JobQueue), "monitor_routific_job", 0)
    end
  end
end
