defmodule ReIntegrations.Salesforce.Mapper.RoutificTest do
  use ReIntegrations.ModelCase
  use Mockery

  import Re.Factory

  alias ReIntegrations.{
    Routific,
    Salesforce.Mapper
  }

  @calendar_uuid Ecto.UUID.generate()

  @visit %{
    id: "0x02",
    start: ~T[12:30:00Z],
    end: ~T[13:00:00Z],
    address: "some address",
    break: false,
    idle_time: 0,
    notes: "",
    custom_notes: %{"account_id" => "0x01", "owner_id" => "0x01"}
  }

  @payload %Routific.Payload.Inbound{
    status: :finished,
    options: %{"date" => "2019-08-01T21:00:00.000+0000"},
    unserved: [],
    solution: %{
      @calendar_uuid => [@visit]
    }
  }

  setup do
    address = insert(:address)
    insert(:calendar, uuid: @calendar_uuid, address: address)
    :ok
  end

  describe "build_event/1" do
    test "builds salesforce event from a routific solution" do
      mock(
        HTTPoison,
        :get,
        {:ok,
         %{
           status_code: 200,
           body: ~s({"Id":"0x01","Name":"name","PersonMobilePhone":""})
         }}
      )

      assert %{
               what_id: "0x02",
               type: :visit,
               start: ~N[2019-08-01 12:30:00.000],
               end: ~N[2019-08-01 13:00:00.000],
               address: "some address",
               duration: 30
             } = Mapper.Routific.build_event(@visit, @calendar_uuid, @payload)

      uri = %URI{path: "/api/v1/Account/0x01"}

      assert_called(HTTPoison, :get, [
        ^uri,
        [{"Authorization", ""}, {"Content-Type", "application/json"}]
      ])
    end

    test "shifts start time by idle_time" do
      mock(
        HTTPoison,
        :get,
        {:ok,
         %{
           status_code: 200,
           body: ~s({"Id":"0x01","Name":"name","PersonMobilePhone":""})
         }}
      )

      assert %{
               start: ~N[2019-08-01 12:30:00.000],
               end: ~N[2019-08-01 13:00:00.000],
               duration: 30
             } =
               @visit
               |> Map.merge(%{
                 start: ~T[12:00:00Z],
                 end: ~T[13:00:00Z],
                 idle_time: 30
               })
               |> Mapper.Routific.build_event(@calendar_uuid, @payload)

      uri = %URI{path: "/api/v1/Account/0x01"}

      assert_called(HTTPoison, :get, [
        ^uri,
        [{"Authorization", ""}, {"Content-Type", "application/json"}]
      ])
    end

    test "rounds minutes to multiples of 5" do
      mock(
        HTTPoison,
        :get,
        {:ok,
         %{
           status_code: 200,
           body: ~s({"Id":"0x01","Name":"name","PersonMobilePhone":""})
         }}
      )

      assert %{
               start: ~N[2019-08-01 12:30:00.000],
               end: ~N[2019-08-01 13:00:00.000]
             } =
               @visit
               |> Map.merge(%{
                 start: ~T[12:32:00Z],
                 end: ~T[12:58:00Z]
               })
               |> Mapper.Routific.build_event(@calendar_uuid, @payload)

      uri = %URI{path: "/api/v1/Account/0x01"}

      assert_called(HTTPoison, :get, [
        ^uri,
        [{"Authorization", ""}, {"Content-Type", "application/json"}]
      ])
    end
  end
end
