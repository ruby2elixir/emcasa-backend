defmodule Re.Developments.JobQueueTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    Developments.JobQueue
  }

  alias Ecto.Multi

  describe "perform/2" do
    test "insert new listing association from new_unit event" do
      address = insert(:address)
      development = insert(:development, address: address)
      %{uuid: uuid} = insert(:unit, development: development)

      assert {:ok, %{listing: %{id: listing_id}}} =
               JobQueue.perform(Multi.new(), %{"type" => "new_unit", "uuid" => uuid})

      {:ok, unit} = Re.Units.get(uuid)
      assert unit.listing_id == listing_id
    end
  end
end
