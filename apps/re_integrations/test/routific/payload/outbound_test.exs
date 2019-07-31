defmodule ReIntegrations.Routific.Payload.OutboundTest do
  use ReIntegrations.ModelCase

  import Re.Factory

  alias ReIntegrations.Routific.Payload

  describe "build/1" do
    setup do
      address = insert(:address)
      district = insert(:district)
      calendar = insert(:calendar, address: address, districts: [district])
      {:ok, district: district, calendar: calendar}
    end

    test "builds routific payload", %{district: district} do
      assert {:ok, %Payload.Outbound{}} =
               Payload.Outbound.build([
                 %{
                   id: "1",
                   duration: 10,
                   address: "x",
                   neighborhood: district.name,
                   lat: 1.0,
                   lng: 1.0
                 }
               ])
    end

    test "builds fleet from calendars", %{district: district, calendar: calendar} do
      assert {:ok, %Payload.Outbound{fleet: fleet}} =
               Payload.Outbound.build([
                 %{
                   id: "1",
                   duration: 10,
                   address: "x",
                   neighborhood: district.name,
                   lat: 1.0,
                   lng: 1.0
                 }
               ])

      assert [calendar.uuid] == Map.keys(fleet)
    end

    test "fails when there are no calendars available" do
      assert {:error, :no_calendars_found} =
               Payload.Outbound.build([
                 %{
                   id: "1",
                   duration: 10,
                   address: "x",
                   neighborhood: "test",
                   lat: 1.0,
                   lng: 1.0
                 }
               ])
    end

    test "validates presence of visit id", %{district: district} do
      assert {:error, :invalid_input} =
               Payload.Outbound.build([
                 %{
                   duration: 10,
                   address: "x",
                   neighborhood: district.name,
                   lat: 1.0,
                   lng: 1.0
                 }
               ])
    end

    test "validates presence of visit location data" do
      assert {:error, :invalid_input} =
               Payload.Outbound.build([
                 %{
                   id: "1",
                   duration: 10
                 }
               ])
    end
  end
end
