defmodule Re.Leads.Buyer.JobQueueTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    Leads.Buyer,
    Leads.Buyer.JobQueue,
    Repo
  }

  alias Ecto.Multi

  describe "grupozap_buyer_lead" do
    test "process lead with existing user and listing" do
      %{id: id, uuid: listing_uuid} = insert(:listing)
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: "11", phone: "999999999", client_listing_id: "#{id}")

      Multi.new()
      |> JobQueue.perform(%{"type" => "grupozap_buyer_lead", "uuid" => uuid})
      |> Repo.transaction()

      assert buyer = Repo.one(Buyer)
      assert buyer.user_uuid == user_uuid
      assert buyer.listing_uuid == listing_uuid
    end

    test "process lead with no user" do
      %{id: id, uuid: listing_uuid} = insert(:listing)

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: "11", phone: "999999999", client_listing_id: "#{id}")

      Multi.new()
      |> JobQueue.perform(%{"type" => "grupozap_buyer_lead", "uuid" => uuid})
      |> Repo.transaction()

      assert buyer = Repo.one(Buyer)
      refute buyer.user_uuid
      assert buyer.listing_uuid == listing_uuid
    end

    test "process lead with no listing" do
      %{id: id} = listing = insert(:listing)
      Repo.delete(listing)
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: "11", phone: "999999999", client_listing_id: "#{id}")

      Multi.new()
      |> JobQueue.perform(%{"type" => "grupozap_buyer_lead", "uuid" => uuid})
      |> Repo.transaction()

      assert buyer = Repo.one(Buyer)
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
    end
  end
end
