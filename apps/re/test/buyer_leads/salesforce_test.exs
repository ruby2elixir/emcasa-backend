defmodule Re.BuyerLeads.SalesforceTest do
  use Re.ModelCase
  use Mockery

  import Re.Factory

  alias Re.BuyerLeads.Salesforce.Client

  describe "create_lead/1" do
    test "should send a request to create a lead" do
      lead = insert(:buyer_lead)

      mock(HTTPoison, :post, {:ok, %{status_code: 200, body: ~s({"status":"success"})}})

      assert {:ok, %{"status" => "success"}} = Client.create_lead(lead)

      {:ok, encoded_lead} = Jason.encode(lead)
      uri = URI.parse("http://www.emcasa.com/salesforce_zapier")

      assert_called(HTTPoison, :post, [^uri, ^encoded_lead])
    end

    test "should not send a request on not handled lead type" do
      mock(HTTPoison, :post, {:ok, %{body: ~s({"status":"success"})}})

      assert {:error, :lead_type_not_handled} = Client.create_lead(%{})

      uri = URI.parse("http://www.emcasa.com/salesforce_zapier")

      refute_called(HTTPoison, :post, [^uri, "{}"])
    end

    test "should handle request error" do
      lead = insert(:buyer_lead)

      mock(HTTPoison, :post, {:error, %HTTPoison.Error{id: nil, reason: :timeout}})

      assert {:error, %{reason: :timeout}} = Client.create_lead(lead)

      {:ok, encoded_lead} = Jason.encode(lead)
      uri = URI.parse("http://www.emcasa.com/salesforce_zapier")

      assert_called(HTTPoison, :post, [^uri, ^encoded_lead])
    end
  end
end
