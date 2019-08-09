defmodule ReIntegrations.Salesforce.Payload.EventTest do
  use ReIntegrations.ModelCase

  alias ReIntegrations.Salesforce.Payload

  @payload %{
    "OwnerId" => "0x02",
    "WhoId" => "0x02",
    "WhatId" => "0x02",
    "Type" => "Visita",
    "Subject" => "some subject",
    "Description" => "some description",
    "Location" => "some address",
    "StartDateTime" => "2019-01-01T00:00:00",
    "EndDateTime" => "2019-01-01T00:00:00",
    "DurationInMinutes" => 30
  }

  @event %Payload.Event{
    id: "0x01",
    owner_id: "0x02",
    who_id: "0x02",
    what_id: "0x02",
    type: "Visita",
    subject: "some subject",
    description: "some description",
    address: "some address",
    start: ~N[2019-01-01 00:00:00],
    end: ~N[2019-01-01 00:00:00],
    duration: 30
  }

  describe "Jason.Encoder" do
    test "maps schema keys to salesforce columns" do
      assert @payload == Jason.encode!(@event) |> Jason.decode!()
    end
  end
end
