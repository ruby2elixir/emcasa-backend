defmodule Re.SellerLeadsTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    PubSub,
    SellerLeads,
    SellerLeads.SiteLead
  }

  describe "create_site" do
    test "should create a seller lead and notify by email" do
      user = insert(:user)
      address = insert(:address)
      price_suggestion_request = insert(:price_suggestion_request, user: user, address: address)
      params = params_for(:site_seller_lead, price_request: price_suggestion_request)

      PubSub.subscribe("new_site_seller_lead")

      {:ok, _site_lead} = SellerLeads.create_site(params)

      assert %{uuid: uuid} = Repo.one(SiteLead)

      assert_received %{topic: "new_site_seller_lead", new: %{uuid: ^uuid}}
    end
  end
end
