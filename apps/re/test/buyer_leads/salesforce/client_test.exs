defmodule Re.BuyerLeads.Salesforce.ClientTest do
  use Re.ModelCase
  use Mockery

  import Re.Factory

  alias Re.BuyerLeads.Salesforce.Client

  describe "create_lead/1" do
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
          user_url: buyer_lead.user_url,
          cpf: buyer_lead.cpf,
          where_did_you_find_about: buyer_lead.where_did_you_find_about
        })

      {:ok, buyer_lead: buyer_lead, encoded_buyer_lead: encoded_buyer_lead}
    end

    test "should send a request to create a lead", %{
      buyer_lead: buyer_lead,
      encoded_buyer_lead: encoded_buyer_lead
    } do
      mock(HTTPoison, :post, {:ok, %{status_code: 200, body: ~s({"status":"success"})}})

      assert {:ok, %{"status" => "success"}} = Client.create_lead(buyer_lead)

      uri = @uri
      assert_called(HTTPoison, :post, [^uri, ^encoded_buyer_lead])
    end

    test "should not send a request on not handled lead type" do
      mock(HTTPoison, :post, {:ok, %{body: ~s({"status":"success"})}})

      assert {:error, :lead_type_not_handled} = Client.create_lead(%{})

      uri = @uri
      refute_called(HTTPoison, :post, [^uri, "{}"])
    end

    test "should handle request error", %{
      buyer_lead: buyer_lead,
      encoded_buyer_lead: encoded_buyer_lead
    } do
      mock(HTTPoison, :post, {:error, %HTTPoison.Error{id: nil, reason: :timeout}})

      assert {:error, %{reason: :timeout}} = Client.create_lead(buyer_lead)

      uri = @uri
      assert_called(HTTPoison, :post, [^uri, ^encoded_buyer_lead])
    end
  end
end
