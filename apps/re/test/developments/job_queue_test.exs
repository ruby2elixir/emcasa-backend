defmodule Re.Developments.JobQueueTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    Developments.JobQueue,
    Repo
  }

  alias Ecto.Multi

  describe "perform/2" do
    @tag dev: true
    test "insert new listing from new_unit event" do
      address = insert(:address)
      development = insert(:development, address: address)
      %{uuid: uuid} = insert(:unit, development: development)

      assert {:ok, _} = JobQueue.perform(Multi.new(), %{"type" => "new_unit", "uuid" => uuid})
      assert Repo.one(Re.Listing)
    end
  end
end
