defmodule Re.SellerLeads.JobQueueTest do
  use Re.ModelCase
  use Mockery

  import Re.Factory
  import Re.CustomAssertion

  alias Re.{
    Repo,
    SellerLead,
    SellerLeads.JobQueue,
    User
  }

  alias Ecto.Multi

  describe "price_suggestion_request" do
    test "process lead" do
      %{uuid: address_uuid} = address = insert(:address)
      %{uuid: user_uuid} = user = insert(:user)

      %{uuid: uuid} =
        price_suggestion_request =
        insert(:price_suggestion_request,
          address: address,
          user: user
        )

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "process_price_suggestion_request",
                 "uuid" => uuid
               })

      assert seller = Repo.one(SellerLead)
      assert_enqueued_job(Repo.all(JobQueue), "create_lead_salesforce")
      assert seller.uuid
      assert seller.user_uuid == user_uuid
      assert seller.address_uuid == address_uuid
      assert seller.source == "WebSite"
      assert seller.complement == nil
      assert seller.type == price_suggestion_request.type
      assert seller.area == price_suggestion_request.area
      assert seller.maintenance_fee == price_suggestion_request.maintenance_fee
      assert seller.rooms == price_suggestion_request.rooms
      assert seller.bathrooms == price_suggestion_request.bathrooms
      assert seller.suites == price_suggestion_request.suites
      assert seller.garage_spots == price_suggestion_request.garage_spots
      assert seller.price == nil
      assert seller.suggested_price == price_suggestion_request.suggested_price
    end

    test "save name in user when nil" do
      address = insert(:address)
      %{uuid: user_uuid} = user = insert(:user, name: nil)

      %{uuid: uuid} =
        insert(:price_suggestion_request,
          name: "mah name",
          address: address,
          user: user
        )

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "process_price_suggestion_request",
                 "uuid" => uuid
               })

      assert seller = Repo.one(SellerLead)
      assert_enqueued_job(Repo.all(JobQueue), "create_lead_salesforce")
      assert user = Repo.get_by(User, uuid: user_uuid)
      assert user.name == "mah name"
    end

    test "save email in user when nil" do
      address = insert(:address)
      %{uuid: user_uuid} = user = insert(:user, email: nil)

      %{uuid: uuid} =
        insert(:price_suggestion_request,
          email: "mahemail@emcasa.com",
          address: address,
          user: user
        )

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "process_price_suggestion_request",
                 "uuid" => uuid
               })

      assert seller = Repo.one(SellerLead)
      assert_enqueued_job(Repo.all(JobQueue), "create_lead_salesforce")
      assert user = Repo.get_by(User, uuid: user_uuid)
      assert user.email == "mahemail@emcasa.com"
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
      user = insert(:user)
      address = insert(:address)
      seller_lead = insert(:seller_lead, user: user, address: address)

      {:ok, encoded_seller_lead} =
        Jason.encode(%{
          name: user.name,
          email: user.email,
          phone: user.phone,
          city: address.city,
          state: address.state,
          street: address.street,
          street_number: address.street_number,
          neighborhood: address.neighborhood,
          postal_code: address.postal_code,
          type: seller_lead.type,
          complement: seller_lead.complement,
          garage_spots: seller_lead.garage_spots,
          area: seller_lead.area,
          bathrooms: seller_lead.bathrooms,
          rooms: seller_lead.rooms,
          suites: seller_lead.suites,
          maintenance_fee: seller_lead.maintenance_fee,
          suggested_price: seller_lead.suggested_price,
          source: seller_lead.source,
          tour_option: seller_lead.tour_option,
          inserted_at: seller_lead.inserted_at,
          uuid: seller_lead.uuid
        })

      {:ok, seller_lead: seller_lead, encoded_seller_lead: encoded_seller_lead}
    end

    test "create lead", %{seller_lead: seller_lead, encoded_seller_lead: encoded_seller_lead} do
      mock(HTTPoison, :post, {:ok, %{status_code: 200, body: ~s({"status":"success"})}})

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "create_lead_salesforce",
                 "uuid" => seller_lead.uuid
               })

      refute Repo.one(JobQueue)
      uri = @uri

      assert_called(HTTPoison, :post, [^uri, ^encoded_seller_lead])
    end

    test "raise when there's a timeout", %{
      seller_lead: seller_lead,
      encoded_seller_lead: encoded_seller_lead
    } do
      mock(HTTPoison, :post, {:error, %{reason: :timeout}})

      assert_raise RuntimeError, fn ->
        assert {:error, _} =
                 JobQueue.perform(Multi.new(), %{
                   "type" => "create_lead_salesforce",
                   "uuid" => seller_lead.uuid
                 })
      end

      uri = @uri

      assert_called(HTTPoison, :post, [^uri, ^encoded_seller_lead])
    end
  end

  describe "not handled jobs" do
    test "raise if not passing a multi" do
      assert_raise RuntimeError, fn ->
        JobQueue.perform(:not_multi, %{})
      end
    end

    test "raise if job type not handled" do
      assert_raise RuntimeError, fn ->
        JobQueue.perform(Multi.new(), %{"type" => "whatever", "uuid" => nil})
      end
    end
  end
end
