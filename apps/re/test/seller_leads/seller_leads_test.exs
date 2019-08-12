defmodule Re.SellerLeadsTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    PubSub,
    SellerLeads,
    SellerLeads.Site
  }

  describe "create_site" do
    test "should create a seller lead and notify by email" do
      user = insert(:user)
      address = insert(:address)
      price_suggestion_request = insert(:price_suggestion_request, user: user, address: address)
      params = params_for(:site_seller_lead, price_request: price_suggestion_request)

      PubSub.subscribe("new_site_seller_lead")

      {:ok, _site_lead} = SellerLeads.create_site(params)

      assert %{uuid: uuid} = Repo.one(Site)

      assert_received %{topic: "new_site_seller_lead", new: %{uuid: ^uuid}}
    end
  end

  describe "duplicated?" do
    test "should be false when the address doesn't exists" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: "Apto. 201")

      refute SellerLeads.duplicated?(address, "Apartamento 401")
    end
    
    test "should be true when the address and the complement is nil" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: nil)

      assert SellerLeads.duplicated?(address, nil)
    end
    
    test "should be true when the address has the exactly same complement" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: "100")

      assert SellerLeads.duplicated?(address, "100")
    end
    
    test "should be true when the seller lead address has a complement with letters" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: "apto 100")

      assert SellerLeads.duplicated?(address, "100")
    end
    
    test "should be true when the passed address has a complement with letters" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: "100")

      assert SellerLeads.duplicated?(address, "apto 100")
    end
    
    test "should be true when the address has a similar complement with letters and multiple groups" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: "Bloco 3 - Apto 200")

      assert SellerLeads.duplicated?(address, "Apto. 200 - Bloco 3")
    end
  end
end
