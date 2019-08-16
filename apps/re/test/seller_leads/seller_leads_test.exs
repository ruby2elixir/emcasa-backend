defmodule Re.SellerLeadsTest do
  use Re.ModelCase

  import Re.Factory

  import Re.CustomAssertion

  alias Re.{
    SellerLeads,
    SellerLeads.JobQueue,
    SellerLeads.Site,
    OwnerContacts
  }

  describe "create_site" do
    test "should create a seller lead and notify by email" do
      user = insert(:user)
      address = insert(:address)
      price_suggestion_request = insert(:price_suggestion_request, user: user, address: address)
      params = params_for(:site_seller_lead, price_request: price_suggestion_request)

      {:ok, _site_lead} = SellerLeads.create_site(params)

      assert Repo.one(Site)
      assert_enqueued_job(Repo.all(JobQueue), "process_site_seller_lead")
    end
  end

  describe "create_broker" do
    test "should create owner as owner contact when it doesn't exists" do
      assert {:error, :not_found} == OwnerContacts.get_by_phone("+5599999999999")
      user = insert(:user, type: "partner_broker")
      address = insert(:address)

      params = %{
        owner: %{
          email: "a@a.com",
          phone: "+5599999999999",
          name: "Suzana Vieira"
        },
        type: "Apartamento",
        broker_uuid: user.uuid,
        address_uuid: address.uuid
      }

      SellerLeads.create_broker(params)
      assert {:ok, owner} = OwnerContacts.get_by_phone("+5599999999999")

      assert %{name: "Suzana Vieira", email: "a@a.com", phone: "+5599999999999"} ==
               Map.take(owner, [:name, :email, :phone])
    end

    test "should not create owner as owner contact when it exists" do
      user = insert(:user, type: "partner_broker")
      owner = insert(:owner_contact)
      address = insert(:address)

      params = %{
        owner: %{
          email: "a@a.com",
          phone: owner.phone,
          name: owner.name
        },
        type: "Apartamento",
        broker_uuid: user.uuid,
        address_uuid: address.uuid
      }

      {:ok, broker} = SellerLeads.create_broker(params)
      assert broker.owner_uuid == owner.uuid
    end
  end

  describe "duplicated?" do
    test "should be false when the address doesn't exists for seller lead" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: "Apto. 201")

      refute SellerLeads.duplicated?(address, "Apartamento 401")
    end

    test "should be true when the address and the complement is nil for seller lead" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: nil)

      assert SellerLeads.duplicated?(address, nil)
    end

    test "should be true when the address has the exactly same complement for seller lead" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: "100")

      assert SellerLeads.duplicated?(address, "100")
    end

    test "should be true when the seller lead address has a complement with letters for seller lead" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: "apto 100")

      assert SellerLeads.duplicated?(address, "100")
    end

    test "should be true when the passed address has a complement with letters for seller lead" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: "100")

      assert SellerLeads.duplicated?(address, "apto 100")
    end

    test "should be true when the address has a similar complement with letters and multiple groups for seller lead" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: "Bloco 3 - Apto 200")

      assert SellerLeads.duplicated?(address, "Apto. 200 - Bloco 3")
    end

    test "should be true when the passed address has a similar complement for a publicated listing" do
      address = insert(:address)
      insert(:listing, address: address, complement: "Bloco 3 - Apto 200")

      assert SellerLeads.duplicated?(address, "Apto. 200 - Bloco 3")
    end

    test "should be false when the passed address is the same address but a different complement as a publicated listing" do
      address = insert(:address)
      insert(:listing, address: address, complement: "Bloco 3 - Apto 320")

      refute SellerLeads.duplicated?(address, "Apto. 200 - Bloco 3")
    end
  end
end
