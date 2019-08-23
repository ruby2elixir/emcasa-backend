defmodule ReIntegrations.Salesforce.Mapper.ZapierTest do
  use ReIntegrations.ModelCase

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

  setup do
    address = insert(:address)
    insert(:calendar, uuid: @calendar_uuid, address: address)
    :ok
  end

  describe "build_report/1" do
    test "payload with scheduled sessions" do
      assert {:ok, %{body: body}} =
               Mapper.Zapier.build_report(%Routific.Payload.Inbound{
                 status: :finished,
                 options: %{"date" => "2019-08-01T21:00:00.000+0000"},
                 unserved: %{},
                 solution: %{
                   @calendar_uuid => [@visit]
                 }
               })

      assert String.contains?(body, "Sessões de tour agendadas")
      assert not String.contains?(body, "Opotunidades não agendadas")
    end

    test "payload with unserved opportunities" do
      assert {:ok, %{body: body}} =
               Mapper.Zapier.build_report(%Routific.Payload.Inbound{
                 status: :finished,
                 options: %{"date" => "2019-08-01T21:00:00.000+0000"},
                 unserved: %{
                   "0x01" => "unserved reason"
                 },
                 solution: %{}
               })

      assert not String.contains?(body, "Sessões de tour agendadas")
      assert String.contains?(body, "Opotunidades não agendadas")
    end

    test "payload with no results" do
      assert {:ok, %{body: body}} =
               Mapper.Zapier.build_report(%Routific.Payload.Inbound{
                 status: :finished,
                 options: %{"date" => "2019-08-01T21:00:00.000+0000"},
                 unserved: %{},
                 solution: %{}
               })

      assert String.contains?(body, "Nenhuma sessão agendada")
    end
  end
end
