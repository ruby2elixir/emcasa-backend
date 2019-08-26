defmodule ReIntegrations.RoutificTest do
  use ReIntegrations.ModelCase
  use Mockery

  import Re.Factory

  alias ReIntegrations.Routific

  @visits [
    %{
      id: "1",
      duration: 10,
      address: "x",
      neighborhood: "Vila Mariana",
      lat: 1.0,
      lng: 1.0
    }
  ]

  setup do
    address = insert(:address)
    calendar = insert(:calendar, address: address)

    payload =
      ~s({) <>
        ~s("fleet":{) <>
        ~s("#{calendar.uuid}":{) <>
        ~s("breaks":[) <>
        ~s({) <>
        ~s("end":"13:00",) <>
        ~s("id":"lunch",) <>
        ~s("start":"12:00") <>
        ~s(}) <>
        ~s(],) <>
        ~s("shift_end":"18:00",) <>
        ~s("shift_start":"08:00",) <>
        ~s("speed":null,) <>
        ~s("start_location":{) <>
        ~s("id":#{address.id},) <>
        ~s("lat":#{address.lat},) <>
        ~s("lng":#{address.lng},) <>
        ~s("name":"#{address.street}, #{address.street_number}") <>
        ~s(},) <>
        ~s("type":[]) <>
        ~s(}) <>
        ~s(},) <>
        ~s("options":{},) <>
        ~s("visits":{) <>
        ~s("1":{) <>
        ~s("customNotes":{},) <>
        ~s("duration":10,) <>
        ~s("end":"18:00",) <>
        ~s("location":{) <>
        ~s("address":"x",) <>
        ~s("name":"x") <>
        ~s(},) <>
        ~s("start":"8:00") <>
        ~s(}) <>
        ~s(}) <>
        ~s(})

    {:ok, payload: payload}
  end

  describe "start_job/1" do
    test "create a new job to monitor routific request", %{payload: payload} do
      mock(HTTPoison, :post, {:ok, %{body: "{\"job_id\": \"100\"}"}})
      assert {:ok, job_id} = Routific.start_job(@visits)
      assert is_binary(job_id)

      uri = %URI{path: "/v1/vrp-long"}

      assert_called(HTTPoison, :post, [
        ^uri,
        ^payload,
        [{"Authorization", "Bearer "}, {"Content-Type", "application/json"}]
      ])
    end
  end

  describe "get_job_status/1" do
    test "fetch routific invalid job" do
      mock(HTTPoison, :get, {:ok, %{status_code: 404}})

      assert {:error, %{status_code: 404}} = Routific.get_job_status("INVALID_JOB_ID")

      uri = %URI{path: "/jobs/INVALID_JOB_ID"}

      assert_called(HTTPoison, :get, [
        ^uri,
        [{"Authorization", "Bearer "}, {"Content-Type", "application/json"}]
      ])
    end

    test "fetch routific pending job" do
      mock(HTTPoison, :get, {:ok, %{status_code: 200, body: ~s({"status":"pending","id":"100"})}})

      assert {:pending, %Routific.Payload.Inbound{status: :pending}} =
               Routific.get_job_status("PENDING_JOB_ID")

      uri = %URI{path: "/jobs/PENDING_JOB_ID"}

      assert_called(HTTPoison, :get, [
        ^uri,
        [{"Authorization", "Bearer "}, {"Content-Type", "application/json"}]
      ])
    end

    test "fetch routific failed job" do
      mock(
        HTTPoison,
        :get,
        {:ok,
         %{
           status_code: 412,
           body: ~s({"status":"error","id":"100","output":"error message"})
         }}
      )

      assert {:error, %Routific.Payload.Inbound{status: :error}} =
               Routific.get_job_status("FAILED_JOB_ID")

      uri = %URI{path: "/jobs/FAILED_JOB_ID"}

      assert_called(HTTPoison, :get, [
        ^uri,
        [{"Authorization", "Bearer "}, {"Content-Type", "application/json"}]
      ])
    end

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

    test "fetch routific finished job" do
      mock(HTTPoison, :get, {:ok, %{status_code: 200, body: @finished_job_payload}})

      assert {:ok, %Routific.Payload.Inbound{status: :finished}} =
               Routific.get_job_status("FINISHED_JOB_ID")

      uri = %URI{path: "/jobs/FINISHED_JOB_ID"}

      assert_called(HTTPoison, :get, [
        ^uri,
        [{"Authorization", "Bearer "}, {"Content-Type", "application/json"}]
      ])
    end
  end
end
