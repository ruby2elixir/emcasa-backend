defmodule Re.SellerLeads.JobQueueTest do
  use Re.ModelCase
  use Mockery

  import Re.Factory
  import Re.CustomAssertion

  alias Re.{
    PriceSuggestions.Request,
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

      assert request = Repo.get_by(Request, uuid: uuid)
      assert request.seller_lead_uuid == seller.uuid
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

    test "should mark as duplicated when another lead with same address and complement exists" do
      address = insert(:address)
      user = insert(:user)

      insert(:seller_lead, address: address, complement: nil)

      %{uuid: uuid} =
        insert(:price_suggestion_request,
          address: address,
          user: user
        )

      assert {:ok, %{insert_seller_lead: seller}} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "process_price_suggestion_request",
                 "uuid" => uuid
               })

      assert seller.duplicated == "almost_sure"
    end

    @tag dev: true
    test "should not mark as duplicated when another lead with other address and complement exists" do
      address = insert(:address)
      user = insert(:user)

      %{uuid: uuid} =
        insert(:price_suggestion_request,
          address: address,
          user: user
        )

      assert {:ok, %{insert_seller_lead: seller}} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "process_price_suggestion_request",
                 "uuid" => uuid
               })

      assert seller.duplicated == "maybe"
    end
  end

  describe "site_seller_lead" do
    test "process lead" do
      %{uuid: uuid} =
        site_seller_lead =
        insert(:site_seller_lead,
          price_request:
            build(:price_suggestion_request,
              seller_lead: build(:seller_lead),
              address: build(:address),
              user: build(:user)
            )
        )

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "process_site_seller_lead",
                 "uuid" => uuid
               })

      assert seller_lead = Repo.one(SellerLead)
      assert_enqueued_job(Repo.all(JobQueue), "update_lead_salesforce")
      assert seller_lead.uuid
      assert seller_lead.complement == site_seller_lead.complement
      assert seller_lead.type == site_seller_lead.type
      assert seller_lead.maintenance_fee == site_seller_lead.maintenance_fee
      assert seller_lead.suites == site_seller_lead.suites
      assert seller_lead.price == site_seller_lead.price
    end
  end

  describe "create_lead_salesforce" do
    test "create lead" do
      seller_lead = insert(:seller_lead, user: build(:user), address: build(:address))

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "create_lead_salesforce",
                 "uuid" => seller_lead.uuid
               })

      refute Repo.one(JobQueue)

      updated_seller_lead = Repo.get(SellerLead, seller_lead.uuid)
      assert updated_seller_lead.salesforce_id == "0x01"
    end
  end

  describe "update_lead_salesforce" do
    test "update lead" do
      seller_lead = insert(:seller_lead, user: build(:user), address: build(:address))

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "update_lead_salesforce",
                 "uuid" => seller_lead.uuid
               })

      refute Repo.one(JobQueue)
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
