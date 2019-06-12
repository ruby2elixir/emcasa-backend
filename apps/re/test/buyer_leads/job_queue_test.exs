defmodule Re.BuyerLeads.JobQueueTest do
  use Re.ModelCase

  import Re.Factory

  import Mockery

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
      %{id: listing_id, uuid: listing_uuid} = insert(:listing)
      mock(HTTPoison, :get, {:ok, %{body: "{\"retailer_item_id\":\"#{listing_id}\"}"}})
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} =
        insert(:facebook_buyer_lead,
          phone_number: "+5511999999999",
          location: "SP",
          budget: "$1000 to $10000",
          neighborhoods: "downtown"
        )

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      assert listing_uuid == buyer.listing_uuid
      assert buyer.location == "sao-paulo|sp"
      assert buyer.budget == "$1000 to $10000"
    end

    test "process lead with nil phone" do
      %{id: listing_id} = insert(:listing)

      mock(HTTPoison, [get: 1], fn _ ->
        {:ok, %{body: "{\"retailer_item_id\":\"#{listing_id}\"}"}}
      end)

      %{uuid: uuid} = insert(:facebook_buyer_lead, phone_number: nil)

      assert {:error, :insert_buyer_lead, _, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      refute Repo.one(BuyerLead)
    end

    test "process lead with no user" do
      %{id: listing_id, uuid: listing_uuid} = insert(:listing)

      mock(HTTPoison, [get: 1], fn _ ->
        {:ok, %{body: "{\"retailer_item_id\":\"#{listing_id}\"}"}}
      end)

      %{uuid: uuid} = insert(:facebook_buyer_lead, phone_number: "+5511999999999")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      refute buyer.user_uuid
      assert listing_uuid == buyer.listing_uuid
    end

    test "process lead with unknown location" do
      %{id: listing_id, uuid: listing_uuid} = insert(:listing)

      mock(HTTPoison, [get: 1], fn _ ->
        {:ok, %{body: "{\"retailer_item_id\":\"#{listing_id}\"}"}}
      end)

      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} = insert(:facebook_buyer_lead, phone_number: "+5511999999999")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      assert listing_uuid == buyer.listing_uuid
      assert buyer.location == "unknown"
    end

    test "process lead with invalid listing" do
      mock(HTTPoison, :get, {:ok, %{body: "{\"retailer_item_id\":\"#{2}\"}"}})
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} =
        insert(:facebook_buyer_lead,
          phone_number: "+5511999999999",
          location: "SP",
          budget: "$1000 to $10000",
          neighborhoods: "downtown"
        )

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
      assert buyer.location == "sao-paulo|sp"
      assert buyer.budget == "$1000 to $10000"
    end

    test "process lead without retailer_item_id" do
      mock(HTTPoison, :get, {:ok, %{body: "{}"}})
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} =
        insert(:facebook_buyer_lead,
          phone_number: "+5511999999999",
          location: "SP",
          budget: "$1000 to $10000",
          neighborhoods: "downtown"
        )

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
      assert buyer.location == "sao-paulo|sp"
      assert buyer.budget == "$1000 to $10000"
    end

    test "process lead with http request error" do
      mock(HTTPoison, :get, {:error, %{error: "some error"}})
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} =
        insert(:facebook_buyer_lead,
          phone_number: "+5511999999999",
          location: "SP",
          budget: "$1000 to $10000",
          neighborhoods: "downtown"
        )

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
      assert buyer.location == "sao-paulo|sp"
      assert buyer.budget == "$1000 to $10000"
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

  describe "process_budget_buyer_lead" do
    test "proecss lead" do
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} =
        insert(:budget_buyer_lead,
          user_uuid: user_uuid,
          city: "New York",
          city_slug: "new-york",
          state: "NY",
          state_slug: "ny"
        )

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "process_budget_buyer_lead",
                 "uuid" => uuid
               })

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      assert buyer.location == "new-york|ny"
    end
  end

  describe "process_empty_search_buyer_lead" do
    test "proecss lead" do
      %{uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} =
        insert(:empty_search_buyer_lead,
          user_uuid: user_uuid,
          city: "New York",
          city_slug: "new-york",
          state: "NY",
          state_slug: "ny",
          url: "https://www.emcasa.com/imoveis/ny/new-york"
        )

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "process_empty_search_buyer_lead",
                 "uuid" => uuid
               })

      assert buyer = Repo.one(BuyerLead)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      assert buyer.location == "new-york|ny"
      assert buyer.url == "https://www.emcasa.com/imoveis/ny/new-york"
    end
  end

  describe "requeue_all/1" do
    test "requeue all failed jobs" do
      {:ok, %{id: id}} =
        JobQueue.new(%{}) |> Ecto.Changeset.change(%{state: "FAILED"}) |> Repo.insert()

      JobQueue.new(%{}) |> Ecto.Changeset.change(%{state: "SCHEDULED"}) |> Repo.insert()
      JobQueue.new(%{}) |> Ecto.Changeset.change(%{state: "AVAILABLE"}) |> Repo.insert()
      JobQueue.new(%{}) |> Ecto.Changeset.change(%{state: "IN_PROGRESS"}) |> Repo.insert()

      JobQueue.requeue_all(Multi.new())

      refute Repo.get_by(JobQueue, state: "FAILED")
      assert job = Repo.get(JobQueue, id)
      assert job.state == "SCHEDULED"
    end
  end
end
