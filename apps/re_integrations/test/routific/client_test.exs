defmodule ReIntegrations.Routific.ClientTest do
  use Re.ModelCase

  alias ReIntegrations.{
    Routific,
    Routific.Client
  }

  @visits [
    %{
      "id" => "1",
      "duration" => 10,
      "address" => "x",
      "lat" => 1,
      "lng" => 1
    },
    %{
      "id" => "2",
      "duration" => 10,
      "start" => "9:00",
      "end" => "9:00",
      "address" => "y",
      "lat" => 1,
      "lng" => 1
    }
  ]

  describe "build_payload/1" do
    test "sets default values to visit time window" do
      assert %{
               "location" => %{
                 "name" => "x",
                 "lat" => 1,
                 "lng" => 1
               },
               "start" => Routific.shift_start(),
               "end" => Routific.shift_end(),
               "duration" => 10
             } == Client.build_payload(@visits)["visits"]["1"]
    end

    test "build routific payload from visits list" do
      assert %{
               "visits" => %{
                 "1" => %{
                   "location" => %{
                     "name" => "x",
                     "lat" => 1,
                     "lng" => 1
                   },
                   "start" => _shift_start,
                   "end" => _shift_end,
                   "duration" => 10
                 },
                 "2" => %{
                   "location" => %{
                     "name" => "y",
                     "lat" => 1,
                     "lng" => 1
                   },
                   "start" => "9:00",
                   "end" => "9:00",
                   "duration" => 10
                 }
               },
               "fleet" => _fleet
             } = Client.build_payload(@visits)
    end
  end
end
