defmodule Re.Developments.JobQueueTest do
  @moduledoc false

  use Re.ModelCase

  import Re.Factory

  alias Re.{
    Developments.JobQueue
  }

  alias Ecto.Multi

  describe "perform/2" do
    test "insert new listing association from mirror_new_unit_to_listing event" do
      address = insert(:address)
      development = insert(:development, address: address)
      %{uuid: uuid} = insert(:unit, development: development)

      assert {:ok, %{mirror_unit: %{id: listing_id}}} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "mirror_new_unit_to_listing",
                 "uuid" => uuid
               })

      {:ok, unit} = Re.Units.get(uuid)
      assert unit.listing_id == listing_id
    end
  end
end
