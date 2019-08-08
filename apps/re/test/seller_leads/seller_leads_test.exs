defmodule Re.SellerLeadsTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    Accounts.Users,
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

  describe "create_broker" do
    test "should create owner as user when it doesn't exists" do
      assert {:error, :not_found} == Users.get_by_phone("+559999999999")
      user = insert(:user,  type: "partner_broker")
      address = insert(:address)
      params = %{
        owner_email: "a@a.com",
        owner_telephone: "+559999999999",
        owner_name: "Suzana Vieira",
        type: "Apartamento",
        broker_uuid: user.uuid,
        address_uuid: address.uuid
      }

      SellerLeads.create_broker(params)
      assert {:ok, user} = Users.get_by_phone("+559999999999")
      assert %{name: "Suzana Vieira", email: "a@a.com", phone: "+559999999999"} == Map.take(user, [:name, :email, :phone])
    end

    test "should not create owner as user when it exists" do
      user = insert(:user,  type: "partner_broker")
      owner = insert(:user,  type: "property_owner")
      address = insert(:address)
      params = %{
        owner_email: "a@a.com",
        owner_telephone: owner.phone,
        owner_name: owner.name,
        type: "Apartamento",
        broker_uuid: user.uuid,
        address_uuid: address.uuid
      }

      {:ok, broker} = SellerLeads.create_broker(params)
      assert broker.owner_uuid == owner.uuid
    end
  end
end
