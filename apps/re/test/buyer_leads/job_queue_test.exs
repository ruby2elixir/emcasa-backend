defmodule Re.BuyerLeads.JobQueueTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    BuyerLead,
    BuyerLeads.JobQueue,
    Repo
  }

  alias Ecto.Multi

  describe "grupozap_buyer_lead" do
    test "process lead with existing user and listing" do
      %{id: id, uuid: listing_uuid} =
        insert(:listing, address: build(:address, state_slug: "ny", city_slug: "manhattan"))

      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: "11", phone: "999999999", client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      assert buyer.listing_uuid == listing_uuid
      assert buyer.location == "manhattan|ny"
    end

    test "process lead with nil ddd" do
      %{id: id, uuid: listing_uuid} = insert(:listing, address: build(:address))

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: nil, phone: "999999999", client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      refute buyer.user_uuid
      assert buyer.listing_uuid == listing_uuid
    end

    test "process lead with nil phone" do
      %{id: id, uuid: listing_uuid} = insert(:listing, address: build(:address))

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: "11", phone: nil, client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      refute buyer.user_uuid
      assert buyer.listing_uuid == listing_uuid
    end

    test "process lead with nil ddd and phone" do
      %{id: id, uuid: listing_uuid} = insert(:listing, address: build(:address))

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: nil, phone: nil, client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      refute buyer.user_uuid
      assert buyer.phone_number == "not informed"
      assert buyer.listing_uuid == listing_uuid
    end

    test "process lead with no user" do
      %{id: id, uuid: listing_uuid} = insert(:listing, address: build(:address))

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: "11", phone: "999999999", client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      refute buyer.user_uuid
      assert buyer.listing_uuid == listing_uuid
    end

    test "process lead with no listing" do
      %{id: id} = listing = insert(:listing, address: build(:address))
      Repo.delete(listing)
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: "11", phone: "999999999", client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
    end
  end

  describe "facebook_buyer_lead" do
    test "process lead with existing user and listing" do
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} = insert(:facebook_buyer_lead, phone_number: "+5511999999999", location: "SP")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
      assert buyer.location == "sao-paulo|sp"
    end

    test "process lead with nil phone" do
      %{uuid: uuid} = insert(:facebook_buyer_lead, phone_number: nil)

      assert {:error, :insert_buyer_lead, _, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      refute Repo.one(BuyerLead)
    end

    test "process lead with no user" do
      %{uuid: uuid} = insert(:facebook_buyer_lead, phone_number: "+5511999999999")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      refute buyer.user_uuid
    end

    test "process lead with unknown location" do
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} = insert(:facebook_buyer_lead, phone_number: "+5511999999999")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
      assert buyer.location == "unknown"
    end
  end

  describe "imovelweb_buyer_lead" do
    test "process lead with existing user and listing" do
      %{id: id, uuid: listing_uuid} =
        insert(:listing, address: build(:address, state_slug: "ny", city_slug: "manhattan"))

      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} = insert(:imovelweb_buyer_lead, phone: "011999999999", listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "imovelweb_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      assert buyer.listing_uuid == listing_uuid
      assert buyer.location == "manhattan|ny"
    end

    test "process lead with nil phone" do
      %{id: id} = insert(:listing, address: build(:address))

      %{uuid: uuid} = insert(:imovelweb_buyer_lead, phone: nil, listing_id: "#{id}")

      assert {:error, :insert_buyer_lead, _, _} =
               JobQueue.perform(Multi.new(), %{"type" => "imovelweb_buyer", "uuid" => uuid})

      refute Repo.one(BuyerLead)
    end

    test "process lead with no user" do
      %{id: id, uuid: listing_uuid} = insert(:listing, address: build(:address))

      %{uuid: uuid} = insert(:imovelweb_buyer_lead, phone: "011999999999", listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "imovelweb_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      refute buyer.user_uuid
      assert buyer.listing_uuid == listing_uuid
    end

    test "process lead with no listing" do
      %{id: id} = listing = insert(:listing, address: build(:address))
      Repo.delete(listing)
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} = insert(:imovelweb_buyer_lead, phone: "011999999999", listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "imovelweb_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
      assert buyer.location == "unknown"
    end
  end

  describe "interest" do
    test "process lead with existing user and listing" do
      %{uuid: listing_uuid} =
        listing =
        insert(:listing, address: build(:address, state_slug: "ny", city_slug: "manhattan"))

      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} = insert(:interest, listing: listing, phone: "+5511999999999")

      assert {:ok, _} = JobQueue.perform(Multi.new(), %{"type" => "interest", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      assert buyer.listing_uuid == listing_uuid
      assert buyer.location == "manhattan|ny"
    end

    test "process lead with nil phone" do
      listing =
        insert(:listing, address: build(:address, state_slug: "ny", city_slug: "manhattan"))

      %{uuid: uuid} = insert(:interest, listing: listing, phone: nil)

      assert {:error, :insert_buyer_lead, _, _} =
               JobQueue.perform(Multi.new(), %{"type" => "interest", "uuid" => uuid})

      refute Repo.one(BuyerLead)
    end

    test "process lead with no user" do
      %{id: id, uuid: listing_uuid} =
        insert(:listing, address: build(:address, state_slug: "ny", city_slug: "manhattan"))

      %{uuid: uuid} = insert(:interest, phone: "011999999999", listing_id: "#{id}")

      assert {:ok, _} = JobQueue.perform(Multi.new(), %{"type" => "interest", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      refute buyer.user_uuid
      assert buyer.phone_number == "011999999999"
      assert buyer.listing_uuid == listing_uuid
      assert buyer.location == "manhattan|ny"
    end
  end
end
