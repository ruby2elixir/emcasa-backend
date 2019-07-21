defmodule ReIntegrations.Routific.Payload.OutboundTest do
  use ReIntegrations.ModelCase

  import Re.Factory

  alias ReIntegrations.Routific.Payload

  describe "build/1" do
    test "builds routific payload" do
      assert {:ok, %Payload.Outbound{}} =
               Payload.Outbound.build([
                 %{
                   id: "1",
                   duration: 10,
                   address: "x",
                   neighborhood: "Vila Mariana",
                   lat: 1.0,
                   lng: 1.0
                 }
               ])
    end

    test "builds fleet from calendars" do
      address = insert(:address)
      district = insert(:district)
      calendar = insert(:calendar, address: address, districts: [district])

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

    test "validates presence of visit id" do
      assert {:error, :invalid_input} =
               Payload.Outbound.build([
                 %{
                   duration: 10,
                   address: "x",
                   neighborhood: "Vila Mariana",
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
