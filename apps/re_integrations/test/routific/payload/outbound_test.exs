defmodule ReIntegrations.Routific.Payload.OutboundTest do
  use ReIntegrations.ModelCase

  import Re.Factory

  alias ReIntegrations.Routific.Payload

  describe "build/1" do
    setup do
      address = insert(:address)
      calendar = insert(:calendar, address: address, types: ["test"])
      {:ok, calendar: calendar, address: address}
    end

    test "builds routific payload" do
      assert {:ok, %Payload.Outbound{}} =
               Payload.Outbound.build(
                 [
                   %{
                     id: "1",
                     duration: 10,
                     address: "x",
                     lat: 1.0,
                     lng: 1.0
                   }
                 ],
                 []
               )
    end

    test "builds fleet from calendars", %{
      calendar: calendar,
      address: address
    } do
      assert {:ok, %Payload.Outbound{fleet: fleet}} =
               Payload.Outbound.build(
                 [
                   %{
                     id: "1",
                     duration: 10,
                     address: "x",
                     lat: 1.0,
                     lng: 1.0
                   }
                 ],
                 []
               )

      assert %{
               speed: speed,
               type: type,
               start_location: start_location,
               shift_start: _shift_start,
               shift_end: _shift_end,
               breaks: _breaks
             } = fleet[calendar.uuid]

      assert calendar.speed == speed
      assert calendar.types == type
      assert address.lat == start_location.lat
      assert address.lng == start_location.lng
    end

    test "adds 1 break to fleets", %{calendar: calendar} do
      {:ok, %Payload.Outbound{fleet: fleet}} =
        Payload.Outbound.build(
          [
            %{
              id: "1",
              duration: 10,
              address: "x",
              lat: 1.0,
              lng: 1.0
            }
          ],
          []
        )

      assert 1 == length(fleet[calendar.uuid].breaks)
    end

    test "validates presence of visit id" do
      assert {:error, :invalid_input} =
               Payload.Outbound.build(
                 [
                   %{
                     duration: 10,
                     address: "x",
                     lat: 1.0,
                     lng: 1.0
                   }
                 ],
                 []
               )
    end

    test "validates presence of visit location data" do
      assert {:error, :invalid_input} =
               Payload.Outbound.build(
                 [
                   %{
                     id: "1",
                     duration: 10
                   }
                 ],
                 []
               )
    end
  end
end
