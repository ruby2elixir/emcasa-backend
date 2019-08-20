defmodule Re.SellerLeadsTest do
  use Re.ModelCase

  import Re.Factory
  import Mockery
  import Re.CustomAssertion

  alias Re.{
    PriceSuggestions.Request,
    SellerLeads,
    SellerLeads.JobQueue,
    SellerLeads.Site,
    OwnerContacts
  }

  setup do
    {:ok, address: insert(:address), user: insert(:user)}
  end

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

  describe "create_price_suggestion/2" do
    test "should store price suggestion request", %{user: user} do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\":26279.0,\"listing_price\":26279.915,\"listing_price_error_q90_min\":25200.0,\"listing_price_error_q90_max\":28544.0,\"listing_price_per_sqr_meter\":560.0,\"listing_average_price_per_sqr_meter\":610.0}"
         }}
      )

      address_params = %{
        street: "street",
        street_number: "street_number",
        neighborhood: "neighborhood",
        city: "city",
        state: "ST",
        postal_code: "12345-123",
        lat: 10.10,
        lng: 10.10
      }

      params = %{
        address: address_params,
        name: "name",
        email: "email@emcasa.com",
        rooms: 2,
        bathrooms: 2,
        area: 30,
        garage_spots: 2,
        suites: 1,
        type: "Apartamento",
        maintenance_fee: 100.00,
        is_covered: true
      }

      assert {:ok, %{suggested_price: 26_279.0}} =
               SellerLeads.create_price_suggestion(params, user)

      assert request = Repo.one(Request)
      assert request.suggested_price == 26_279.0
    end

    test "should store price suggestion request with user attached", %{user: user} do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\":26279.0,\"listing_price\":26279.915,\"listing_price_error_q90_min\":25200.0,\"listing_price_error_q90_max\":28544.0,\"listing_price_per_sqr_meter\":560.0,\"listing_average_price_per_sqr_meter\":610.0}"
         }}
      )

      address_params = %{
        street: "street",
        street_number: "street_number",
        neighborhood: "neighborhood",
        city: "city",
        state: "ST",
        postal_code: "12345-123",
        lat: 10.10,
        lng: 10.10
      }

      params = %{
        address: address_params,
        name: "name",
        email: "email@emcasa.com",
        rooms: 2,
        bathrooms: 2,
        area: 30,
        garage_spots: 2,
        suites: 1,
        type: "Apartamento",
        maintenance_fee: 100.00,
        is_covered: true
      }

      assert {:ok, %{suggested_price: 26_279.0}} =
               SellerLeads.create_price_suggestion(params, user)

      assert request = Repo.one(Request)
      assert request.user_id == user.id
      assert request.suggested_price == 26_279.0
    end

    test "should not store price suggestion request without user" do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\":26279.0,\"listing_price\":26279.915,\"listing_price_error_q90_min\":25200.0,\"listing_price_error_q90_max\":28544.0,\"listing_price_per_sqr_meter\":560.0,\"listing_average_price_per_sqr_meter\":610.0}"
         }}
      )

      address_params = %{
        street: "street",
        street_number: "street_number",
        neighborhood: "neighborhood",
        city: "city",
        state: "ST",
        postal_code: "12345-123",
        lat: 10.10,
        lng: 10.10
      }

      params = %{
        address: address_params,
        name: "name",
        email: "email@emcasa.com",
        rooms: 2,
        bathrooms: 2,
        area: 30,
        garage_spots: 2,
        suites: 1,
        type: "Apartamento",
        maintenance_fee: 100.00,
        is_covered: true
      }

      assert {:error, :bad_request} = SellerLeads.create_price_suggestion(params, nil)

      refute Repo.one(Request)
    end

    test "should not create process request when neighborhood is not covered", %{user: user} do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\":26279.0,\"listing_price\":26279.915,\"listing_price_error_q90_min\":25200.0,\"listing_price_error_q90_max\":28544.0,\"listing_price_per_sqr_meter\":560.0,\"listing_average_price_per_sqr_meter\":610.0}"
         }}
      )

      address_params = %{
        street: "street",
        street_number: "street_number",
        neighborhood: "neighborhood",
        city: "city",
        state: "ST",
        postal_code: "12345-123",
        lat: 10.10,
        lng: 10.10
      }

      params = %{
        address: address_params,
        name: "name",
        email: "email@emcasa.com",
        rooms: 2,
        bathrooms: 2,
        area: 30,
        garage_spots: 2,
        suites: 1,
        type: "Apartamento",
        maintenance_fee: 100.00,
        is_covered: false
      }

      SellerLeads.create_price_suggestion(params, user)

      refute Repo.one(Re.SellerLeads.JobQueue)
    end
  end

  describe "create_out_of_coverage/1" do
    test "should request notification for address with user" do
      {:ok, notify_when_covered} =
        SellerLeads.create_out_of_coverage(%{
          name: "naem",
          phone: "1920381",
          email: "user@emcasa.com",
          message: "message",
          state: "SP",
          city: "São Paulo",
          neighborhood: "Morumbi"
        })

      assert "naem" == notify_when_covered.name
      assert "1920381" == notify_when_covered.phone
      assert "user@emcasa.com" == notify_when_covered.email
      assert "message" == notify_when_covered.message
      assert "SP" == notify_when_covered.state
      assert "São Paulo" == notify_when_covered.city
      assert "Morumbi" == notify_when_covered.neighborhood
    end

    test "should not request notification without address" do
      {:error, changeset} = SellerLeads.create_out_of_coverage(%{})

      assert [
               state: {"can't be blank", [validation: :required]},
               city: {"can't be blank", [validation: :required]},
               neighborhood: {"can't be blank", [validation: :required]}
             ] == changeset.errors
    end
  end
end
