defmodule ReIntegrations.Routific.Payload.OutboundTest do
  use ReIntegrations.ModelCase

  alias ReIntegrations.Routific.Payload

  describe "build/1" do
    test "builds routific payload" do
      assert {:ok, %Payload.Outbound{}} =
               Payload.Outbound.build([
                 %{
                   id: "1",
                   duration: 10,
                   address: "x",
                   lat: 1.0,
                   lng: 1.0
                 }
               ])
    end

    test "validates presence of visit id" do
      assert {:error, _} =
               Payload.Outbound.build([
                 %{
                   duration: 10,
                   address: "x",
                   lat: 1.0,
                   lng: 1.0
                 }
               ])
    end

    test "validates presence of visit location data" do
      assert {:error, _} =
               Payload.Outbound.build([
                 %{
                   id: "1",
                   duration: 10
                 }
               ])
    end
  end
end
