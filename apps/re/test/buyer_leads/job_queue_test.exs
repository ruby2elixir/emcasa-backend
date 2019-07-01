defmodule Re.BuyerLeads.JobQueueTest do
  use Re.ModelCase
  use Mockery

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

      %{id: user_id, uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: "11", phone: "999999999", client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert Repo.one(JobQueue)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      assert buyer.listing_uuid == listing_uuid
      assert buyer.location == "manhattan|ny"
      assert buyer.user_url == "http://localhost:3000/usuarios/#{user_id}"
    end

    test "process lead with nil ddd" do
      %{id: id, uuid: listing_uuid} = insert(:listing, address: build(:address))

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: nil, phone: "999999999", client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert Repo.one(JobQueue)
      assert buyer.uuid
      refute buyer.user_uuid
      assert buyer.listing_uuid == listing_uuid
      refute buyer.user_url
    end

    test "process lead with nil phone" do
      %{id: id, uuid: listing_uuid} = insert(:listing, address: build(:address))

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: "11", phone: nil, client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert Repo.one(JobQueue)
      assert buyer.uuid
      refute buyer.user_uuid
      assert buyer.listing_uuid == listing_uuid
      refute buyer.user_url
    end

    test "process lead with nil ddd and phone" do
      %{id: id, uuid: listing_uuid} = insert(:listing, address: build(:address))

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: nil, phone: nil, client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert Repo.one(JobQueue)
      assert buyer.uuid
      refute buyer.user_uuid
      assert buyer.phone_number == "not informed"
      assert buyer.listing_uuid == listing_uuid
      refute buyer.user_url
    end

    test "process lead with no user" do
      %{id: id, uuid: listing_uuid} = insert(:listing, address: build(:address))

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: "11", phone: "999999999", client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert Repo.one(JobQueue)
      assert buyer.uuid
      refute buyer.user_uuid
      assert buyer.listing_uuid == listing_uuid
      refute buyer.user_url
    end

    test "process lead with no listing" do
      %{id: id} = listing = insert(:listing, address: build(:address))
      Repo.delete(listing)
      %{id: user_id, uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} =
        insert(:grupozap_buyer_lead, ddd: "11", phone: "999999999", client_listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "grupozap_buyer_lead", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert Repo.one(JobQueue)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
      assert buyer.user_url == "http://localhost:3000/usuarios/#{user_id}"
    end
  end

  describe "facebook_buyer_lead" do
    test "process lead with existing user and listing" do
      %{id: listing_id, uuid: listing_uuid} = insert(:listing, address: address = build(:address))
      mock(HTTPoison, :get, {:ok, %{body: "{\"retailer_item_id\":\"#{listing_id}\"}"}})
      %{id: user_id, uuid: user_uuid} = insert(:user, phone: "+5511999999999")

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
      assert Repo.one(JobQueue)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      assert listing_uuid == buyer.listing_uuid
      assert buyer.location == "#{address.city_slug}|#{address.state_slug}"
      assert buyer.budget == "$1000 to $10000"
      assert buyer.user_url == "http://localhost:3000/usuarios/#{user_id}"
    end

    test "process lead with nil phone" do
      %{id: listing_id} = insert(:listing, address: build(:address))

      mock(HTTPoison, [get: 1], fn _ ->
        {:ok, %{body: "{\"retailer_item_id\":\"#{listing_id}\"}"}}
      end)

      %{uuid: uuid} = insert(:facebook_buyer_lead, phone_number: nil)

      JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      assert Repo.one(BuyerLead)
    end

    test "process lead with no user" do
      %{id: listing_id, uuid: listing_uuid} = insert(:listing, address: build(:address))

      mock(HTTPoison, [get: 1], fn _ ->
        {:ok, %{body: "{\"retailer_item_id\":\"#{listing_id}\"}"}}
      end)

      %{uuid: uuid} = insert(:facebook_buyer_lead, phone_number: "+5511999999999")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert Repo.one(JobQueue)
      assert buyer.uuid
      refute buyer.user_uuid
      assert listing_uuid == buyer.listing_uuid
      refute buyer.user_url
    end

    test "process lead with unknown location" do
      %{id: listing_id, uuid: listing_uuid} = insert(:listing, address: address = build(:address))

      mock(HTTPoison, [get: 1], fn _ ->
        {:ok, %{body: "{\"retailer_item_id\":\"#{listing_id}\"}"}}
      end)

      %{id: user_id, uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} = insert(:facebook_buyer_lead, phone_number: "+5511999999999")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "facebook_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert Repo.one(JobQueue)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      assert listing_uuid == buyer.listing_uuid
      assert buyer.location == "#{address.city_slug}|#{address.state_slug}"
      assert buyer.user_url == "http://localhost:3000/usuarios/#{user_id}"
    end

    test "process lead with invalid listing" do
      mock(HTTPoison, :get, {:ok, %{body: "{\"retailer_item_id\":\"#{2}\"}"}})
      %{id: user_id, uuid: user_uuid} = insert(:user, phone: "+5511999999999")

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
      assert Repo.one(JobQueue)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
      assert buyer.location == "sao-paulo|sp"
      assert buyer.budget == "$1000 to $10000"
      assert buyer.user_url == "http://localhost:3000/usuarios/#{user_id}"
    end

    test "process lead without retailer_item_id" do
      mock(HTTPoison, :get, {:ok, %{body: "{}"}})
      %{id: user_id, uuid: user_uuid} = insert(:user, phone: "+5511999999999")

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
      assert Repo.one(JobQueue)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
      assert buyer.location == "sao-paulo|sp"
      assert buyer.budget == "$1000 to $10000"
      assert buyer.user_url == "http://localhost:3000/usuarios/#{user_id}"
    end

    test "process lead with http request error" do
      mock(HTTPoison, :get, {:error, %{error: "some error"}})
      %{id: user_id, uuid: user_uuid} = insert(:user, phone: "+5511999999999")

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
      assert Repo.one(JobQueue)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
      assert buyer.location == "sao-paulo|sp"
      assert buyer.budget == "$1000 to $10000"
      assert buyer.user_url == "http://localhost:3000/usuarios/#{user_id}"
    end
  end

  describe "imovelweb_buyer_lead" do
    test "process lead with existing user and listing" do
      %{id: id, uuid: listing_uuid} =
        insert(:listing, address: build(:address, state_slug: "ny", city_slug: "manhattan"))

      %{id: user_id, uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} = insert(:imovelweb_buyer_lead, phone: "011999999999", listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "imovelweb_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert Repo.one(JobQueue)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      assert buyer.listing_uuid == listing_uuid
      assert buyer.location == "manhattan|ny"
      assert buyer.user_url == "http://localhost:3000/usuarios/#{user_id}"
    end

    test "process lead with nil phone" do
      %{id: id} = insert(:listing, address: build(:address))

      %{uuid: uuid} = insert(:imovelweb_buyer_lead, phone: nil, listing_id: "#{id}")

      JobQueue.perform(Multi.new(), %{"type" => "imovelweb_buyer", "uuid" => uuid})

      assert Repo.one(BuyerLead)
    end

    test "process lead with no user" do
      %{id: id, uuid: listing_uuid} = insert(:listing, address: build(:address))

      %{uuid: uuid} = insert(:imovelweb_buyer_lead, phone: "011999999999", listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "imovelweb_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert Repo.one(JobQueue)
      assert buyer.uuid
      refute buyer.user_uuid
      assert buyer.listing_uuid == listing_uuid
      refute buyer.user_url
    end

    test "process lead with no listing" do
      %{id: id} = listing = insert(:listing, address: build(:address))
      Repo.delete(listing)
      %{id: user_id, uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} = insert(:imovelweb_buyer_lead, phone: "011999999999", listing_id: "#{id}")

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{"type" => "imovelweb_buyer", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert Repo.one(JobQueue)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      refute buyer.listing_uuid
      assert buyer.location == "unknown"
      assert buyer.user_url == "http://localhost:3000/usuarios/#{user_id}"
    end
  end

  describe "interest" do
    test "process lead with existing user and listing" do
      %{uuid: listing_uuid} =
        listing =
        insert(:listing, address: build(:address, state_slug: "ny", city_slug: "manhattan"))

      %{id: user_id, uuid: user_uuid} = insert(:user, phone: "+5511999999999")

      %{uuid: uuid} = insert(:interest, listing: listing, phone: "+5511999999999")

      assert {:ok, _} = JobQueue.perform(Multi.new(), %{"type" => "interest", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert Repo.one(JobQueue)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      assert buyer.listing_uuid == listing_uuid
      assert buyer.location == "manhattan|ny"
      assert buyer.user_url == "http://localhost:3000/usuarios/#{user_id}"
    end

    test "process lead with nil phone" do
      listing =
        insert(:listing, address: build(:address, state_slug: "ny", city_slug: "manhattan"))

      %{uuid: uuid} = insert(:interest, listing: listing, phone: nil)

      JobQueue.perform(Multi.new(), %{"type" => "interest", "uuid" => uuid})

      assert Repo.one(BuyerLead)
    end

    test "process lead with no user" do
      %{id: id, uuid: listing_uuid} =
        insert(:listing, address: build(:address, state_slug: "ny", city_slug: "manhattan"))

      %{uuid: uuid} = insert(:interest, phone: "011999999999", listing_id: "#{id}")

      assert {:ok, _} = JobQueue.perform(Multi.new(), %{"type" => "interest", "uuid" => uuid})

      assert buyer = Repo.one(BuyerLead)
      assert Repo.one(JobQueue)
      assert buyer.uuid
      refute buyer.user_uuid
      assert buyer.phone_number == "011999999999"
      assert buyer.listing_uuid == listing_uuid
      assert buyer.location == "manhattan|ny"
      refute buyer.user_url
    end
  end

  describe "process_budget_buyer_lead" do
    test "proecss lead" do
      %{id: user_id, uuid: user_uuid} = insert(:user, phone: "+5511999999999")

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
      assert Repo.one(JobQueue)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      assert buyer.location == "new-york|ny"
      assert buyer.user_url == "http://localhost:3000/usuarios/#{user_id}"
    end
  end

  describe "process_empty_search_buyer_lead" do
    test "proecss lead" do
      %{id: user_id, uuid: user_uuid} = insert(:user, phone: "+5511999999999")

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
      assert Repo.one(JobQueue)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      assert buyer.location == "new-york|ny"
      assert buyer.url == "https://www.emcasa.com/imoveis/ny/new-york"
      assert buyer.user_url == "http://localhost:3000/usuarios/#{user_id}"
    end

    test "proecss lead with nil name" do
      %{id: user_id, uuid: user_uuid} = insert(:user, phone: "+5511999999999", name: nil)

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
      assert Repo.one(JobQueue)
      assert buyer.uuid
      assert buyer.user_uuid == user_uuid
      assert buyer.location == "new-york|ny"
      assert buyer.url == "https://www.emcasa.com/imoveis/ny/new-york"
      assert buyer.user_url == "http://localhost:3000/usuarios/#{user_id}"
    end
  end

  describe "requeue_all/1" do
    test "requeue all failed jobs" do
      {:ok, %{id: id}} =
        %{} |> JobQueue.new() |> Ecto.Changeset.change(%{state: "FAILED"}) |> Repo.insert()

      %{} |> JobQueue.new() |> Ecto.Changeset.change(%{state: "SCHEDULED"}) |> Repo.insert()
      %{} |> JobQueue.new() |> Ecto.Changeset.change(%{state: "AVAILABLE"}) |> Repo.insert()
      %{} |> JobQueue.new() |> Ecto.Changeset.change(%{state: "IN_PROGRESS"}) |> Repo.insert()

      JobQueue.requeue_all(Multi.new())

      refute Repo.get_by(JobQueue, state: "FAILED")
      assert job = Repo.get(JobQueue, id)
      assert job.state == "SCHEDULED"
    end
  end

  describe "create_lead_salesforce" do
    @uri %URI{
      authority: "www.emcasa.com",
      fragment: nil,
      host: "www.emcasa.com",
      path: "/salesforce_zapier",
      port: 80,
      query: nil,
      scheme: "http",
      userinfo: nil
    }

    setup do
      buyer_lead = insert(:buyer_lead, phone_number: "+5511999999999")

      {:ok, encoded_buyer_lead} =
        Jason.encode(%{
          uuid: buyer_lead.uuid,
          name: buyer_lead.name,
          phone_number: "5511999999999",
          origin: buyer_lead.origin,
          email: buyer_lead.email,
          location: buyer_lead.location,
          listing_uuid: buyer_lead.listing_uuid,
          user_uuid: buyer_lead.user_uuid,
          budget: buyer_lead.budget,
          neighborhood: buyer_lead.neighborhood,
          url: buyer_lead.url,
          user_url: buyer_lead.user_url
        })

      {:ok, buyer_lead: buyer_lead, encoded_buyer_lead: encoded_buyer_lead}
    end

    test "create lead", %{buyer_lead: buyer_lead, encoded_buyer_lead: encoded_buyer_lead} do
      mock(HTTPoison, :post, {:ok, %{status_code: 200, body: ~s({"status":"success"})}})

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "create_lead_salesforce",
                 "uuid" => buyer_lead.uuid
               })

      refute Repo.one(JobQueue)
      uri = @uri

      assert_called(HTTPoison, :post, [^uri, ^encoded_buyer_lead])
    end

    test "raise when there's a timeout", %{
      buyer_lead: buyer_lead,
      encoded_buyer_lead: encoded_buyer_lead
    } do
      mock(HTTPoison, :post, {:error, %{reason: :timeout}})

      assert_raise RuntimeError, fn ->
        assert {:error, _} =
                 JobQueue.perform(Multi.new(), %{
                   "type" => "create_lead_salesforce",
                   "uuid" => buyer_lead.uuid
                 })
      end

      uri = @uri

      assert_called(HTTPoison, :post, [^uri, ^encoded_buyer_lead])
    end
  end
end
