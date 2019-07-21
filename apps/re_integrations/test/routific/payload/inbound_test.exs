defmodule ReIntegrations.Routific.Payload.InboundTest do
  use ReIntegrations.ModelCase

  import Re.CustomAssertion

  alias ReIntegrations.Routific.Payload

  @finished_response %{
    "status" => "finished",
    "output" => %{
      "status" => "success",
      "unserved" => nil,
      "solution" => %{
        "a" => [
          %{"location_id" => "1", "location_name" => "location 1", "arrival_time" => "08:00"},
          %{"location_id" => "2", "location_name" => "location 2", "arrival_time" => "08:30"}
        ]
      }
    }
  }

  defp get_location_id(%{"location_id" => id}), do: id
  defp get_location_id(%{id: id}), do: id

  defp map_solution(list),
    do: Enum.map(list, fn {id, visits} -> {id, Enum.map(visits, &get_location_id/1)} end)

  describe "build/1" do
    test "builds payload from routific response" do
      assert {:ok, %Payload.Inbound{solution: solution}} =
               Payload.Inbound.build(@finished_response)

      assert_mapper_match(solution, @finished_response["output"]["solution"], &map_solution/1)
    end

    test "validates response status" do
      assert {:ok, %Payload.Inbound{status: :finished}} =
               Payload.Inbound.build(@finished_response)

      assert {:ok, %Payload.Inbound{status: :pending}} =
               Payload.Inbound.build(%{"status" => "pending"})

      assert {:ok, %Payload.Inbound{status: :error}} =
               Payload.Inbound.build(%{"status" => "error"})

      assert {:error, _} = Payload.Inbound.build(%{"status" => "xxx"})
    end
  end
end
