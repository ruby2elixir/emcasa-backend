defmodule Re.SellerLeads.Salesforce.ClientTest do
  use Re.ModelCase
  use Mockery

  import Re.Factory

  alias Re.SellerLeads.Salesforce.Client

  describe "create_lead/1" do
    test "should send a request to create a lead" do
      seller_lead = insert(:seller_lead, user: build(:user), address: build(:address))
      assert {:ok, %{"success" => true}} = Client.create_lead(seller_lead)
    end

    test "should not send a request on not handled lead type" do
      assert {:error, :lead_type_not_handled} = Client.create_lead(%{})
    end
  end
end
