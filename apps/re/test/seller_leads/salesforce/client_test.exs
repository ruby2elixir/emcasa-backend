defmodule Re.SellerLeads.Salesforce.ClientTest do
  use Re.ModelCase
  use Mockery

  import Re.Factory

  alias Re.SellerLeads.Salesforce.Client

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
          price: seller_lead.price,
          source: seller_lead.source,
          tour_option: seller_lead.tour_option,
          inserted_at: seller_lead.inserted_at,
          uuid: seller_lead.uuid
        })

      {:ok, seller_lead: seller_lead, encoded_seller_lead: encoded_seller_lead}
    end

    test "should send a request to create a lead", %{
      seller_lead: seller_lead,
      encoded_seller_lead: encoded_seller_lead
    } do
      mock(HTTPoison, :post, {:ok, %{status_code: 200, body: ~s({"status":"success"})}})

      assert {:ok, %{"status" => "success"}} = Client.create_lead(seller_lead)

      uri = @uri
      assert_called(HTTPoison, :post, [^uri, ^encoded_seller_lead])
    end

    test "should not send a request on not handled lead type" do
      mock(HTTPoison, :post, {:ok, %{body: ~s({"status":"success"})}})

      assert {:error, :lead_type_not_handled} = Client.create_lead(%{})

      uri = @uri
      refute_called(HTTPoison, :post, [^uri, "{}"])
    end

    test "should handle request error", %{
      seller_lead: seller_lead,
      encoded_seller_lead: encoded_seller_lead
    } do
      mock(HTTPoison, :post, {:error, %HTTPoison.Error{id: nil, reason: :timeout}})

      assert {:error, %{reason: :timeout}} = Client.create_lead(seller_lead)

      uri = @uri
      assert_called(HTTPoison, :post, [^uri, ^encoded_seller_lead])
    end
  end
end
