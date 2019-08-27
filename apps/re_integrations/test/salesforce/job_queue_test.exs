defmodule ReIntegrations.Salesforce.JobQueueTest do
  use ReIntegrations.ModelCase
  use Mockery

  import Re.CustomAssertion

  import Re.Factory

  alias ReIntegrations.{
    Repo,
    Routific,
    Salesforce.JobQueue
  }

  alias Ecto.Multi

  setup do
    address = insert(:address)
    insert(:calendar, uuid: "affb1f63-399a-4d85-9f65-c127994104f6", address: address)
    :ok
  end

  describe "monitor_routific_job" do
    @finished_job_payload """
    {
      "status": "finished",
      "id": "100",
      "input": {
        "visits": {
          "1": {"notes": "", "customNotes": {"account_id":"0x01", "owner_id":"0x01"}},
          "2": {"notes": "", "customNotes": {"account_id":"0x01", "owner_id":"0x01"}}
        },
        "fleet": {},
        "options": {"date": "2019-08-01T20:03:48.347904Z"}
      },
      "output": {
        "unserved": {
          "3": "No vehicle available during the specified time windows."
        },
        "solution": {
           "affb1f63-399a-4d85-9f65-c127994104f6": [
             {
               "location_id": "depot",
               "location_name": "depot",
               "arrival_time": "08:00"
             },
             {
               "location_id": "2",
               "location_name": "Rua Vergueiro, 3475",
               "arrival_time": "08:10",
               "finish_time": "08:40"
             },
             {
               "location_id": "1",
               "location_name": "R. Francisco Cruz, 345",
               "arrival_time": "08:41",
               "finish_time": "09:11"
             },
             {
               "break": true,
               "location_id": "nowhere",
               "arrival_time": "10:00",
               "finish_time": "11:00"
             }
           ]
        }
      }
    }
    """

    test "enqueues salesforce events for insertion when routific job succeeds" do
      mock(HTTPoison, [get: 2], fn
        %URI{path: "/jobs/FINISHED_JOB_ID"}, _ ->
          {:ok, %{status_code: 200, body: @finished_job_payload}}

        %URI{path: "/api/v1/User/0x01"}, _ ->
          {:ok,
           %{
             status_code: 200,
             body: ~s({"Id":"0x01","Name":"name"})
           }}

        %URI{path: "/api/v1/Account/0x01"}, _ ->
          {:ok,
           %{
             status_code: 200,
             body: ~s({"Id":"0x01","Name":"name","PersonMobilePhone":"11999999999"})
           }}
      end)

      mock(HTTPoison, :post, {:ok, %{status_code: 200}})

      assert {:ok,
              %{
                get_job_status: %Routific.Payload.Inbound{},
                send_notification: %{status_code: 200}
              }} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "monitor_routific_job",
                 "job_id" => "FINISHED_JOB_ID"
               })

      assert_enqueued_job(Repo.all(JobQueue), "insert_event", 2)
      assert_enqueued_job(Repo.all(JobQueue), "update_opportunity", 1)

      zapier_uri = %URI{
        authority: "example.com",
        host: "example.com",
        path: "/zapier/webhook",
        port: 443,
        scheme: "https"
      }

      zapier_body =
        ~s({"body":"Sessões de tour agendadas para 01/08:\\n**:\\n• [</2/view|2>] 08:10 - 08:40 | Rua Vergueiro, 3475\\n• [</1/view|1>] 08:41 - 09:11 | R. Francisco Cruz, 345\\n\\nOpotunidades não agendadas:\\n• [</3/view|3>] No vehicle available during the specified time windows."})

      assert_called(HTTPoison, :get, [
        %URI{path: "/jobs/FINISHED_JOB_ID"},
        [{"Authorization", "Bearer "}, {"Content-Type", "application/json"}]
      ])

      assert_called(HTTPoison, :get, [
        %URI{path: "/api/v1/User/0x01"},
        [{"Authorization", ""}, {"Content-Type", "application/json"}]
      ])

      assert_called(HTTPoison, :post, [^zapier_uri, ^zapier_body, []])
    end

    test "fails when routific job is pending" do
      mock(HTTPoison, :get, {:ok, %{status_code: 200, body: ~s({"status":"pending","id":"100"})}})

      assert {:error, _, _, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "monitor_routific_job",
                 "job_id" => "PENDING_JOB_ID"
               })

      uri = %URI{path: "/jobs/PENDING_JOB_ID"}

      assert_called(HTTPoison, :get, [
        ^uri,
        [{"Authorization", "Bearer "}, {"Content-Type", "application/json"}]
      ])
    end

    test "raises when routific job fails" do
      mock(
        HTTPoison,
        :get,
        {:ok,
         %{status_code: 412, body: ~s({"status":"error","id":"100","output":"error message"})}}
      )

      assert_raise RuntimeError, fn ->
        JobQueue.perform(Multi.new(), %{
          "type" => "monitor_routific_job",
          "job_id" => "FAILED_JOB_ID"
        })
      end

      uri = %URI{path: "/jobs/FAILED_JOB_ID"}

      assert_called(HTTPoison, :get, [
        ^uri,
        [{"Authorization", "Bearer "}, {"Content-Type", "application/json"}]
      ])
    end
  end

  describe "insert_event" do
    @event %{
      "start" => "2019-08-26T01:00:00",
      "end" => "2019-08-26T01:00:00",
      "duration" => 60,
      "type" => "visit",
      "subject" => "some subject"
    }

    test "enqueues salesforce opportunity update" do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           status_code: 200,
           body:
             ~s({"Id":"0x01","AccountId":"0x01","OwnerId":"0x01","WhoId":"0x01","WhatId":"0x01","Type":"Event","Subject":"some subject","Description":"some description","Location":"some location","DurationInMinutes":60,"StartDateTime":"2019-08-01T21:00:00.000+0000","EndDateTime":"2019-08-01T21:00:00.000+0000"})
         }}
      )

      JobQueue.perform(Multi.new(), %{
        "type" => "insert_event",
        "opportunity_id" => "0x01",
        "route_id" => "test",
        "event" => @event
      })

      assert_enqueued_job(Repo.all(JobQueue), "update_opportunity")

      uri = %URI{path: "/api/v1/Event"}

      body =
        ~s({"Description":null,"DurationInMinutes":60,"EndDateTime":"2019-08-26T01:00:00","Location":null,"OwnerId":null,"StartDateTime":"2019-08-26T01:00:00","Subject":"some subject","Type":"Visita","WhatId":null,"WhoId":null})

      assert_called(HTTPoison, :post, [
        ^uri,
        ^body,
        [{"Authorization", ""}, {"Content-Type", "application/json"}]
      ])
    end

    test "creates a salesforce event" do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           status_code: 200,
           body:
             ~s({"Id":"0x01","AccountId":"0x01","OwnerId":"0x01","WhoId":"0x01","WhatId":"0x01","Type":"Event","Subject":"some subject","Description":"some description","Location":"some location","DurationInMinutes":60,"StartDateTime":"2019-08-01T21:00:00.000+0000","EndDateTime":"2019-08-01T21:00:00.000+0000"})
         }}
      )

      assert {:ok, %{insert_event: %{"Id" => "0x01"}}} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "insert_event",
                 "opportunity_id" => "0x01",
                 "route_id" => "test",
                 "event" => @event
               })

      uri = %URI{path: "/api/v1/Event"}

      body =
        ~s({"Description":null,"DurationInMinutes":60,"EndDateTime":"2019-08-26T01:00:00","Location":null,"OwnerId":null,"StartDateTime":"2019-08-26T01:00:00","Subject":"some subject","Type":"Visita","WhatId":null,"WhoId":null})

      assert_called(HTTPoison, :post, [
        ^uri,
        ^body,
        [{"Authorization", ""}, {"Content-Type", "application/json"}]
      ])
    end
  end

  describe "update_opportunity" do
    test "updates a salesforce opportunity" do
      mock(HTTPoison, :patch, {:ok, %{status_code: 200, body: ~s({"Id":"0x01"})}})

      assert {:ok, %{update_opportunity: %{"Id" => "0x01"}}} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "update_opportunity",
                 "id" => "0x01",
                 "opportunity" => %{"notes" => "new note"}
               })

      uri = %URI{path: "/api/v1/Opportunity/0x01"}
      body = ~s({"Comentarios_do_Agendamento__c":"new note"})

      assert_called(HTTPoison, :patch, [
        ^uri,
        ^body,
        [{"Authorization", ""}, {"Content-Type", "application/json"}]
      ])
    end
  end
end
