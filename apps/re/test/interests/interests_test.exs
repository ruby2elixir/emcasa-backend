defmodule Re.InterestsTest do
  use Re.ModelCase

  alias Re.{
    BuyerLeads.JobQueue,
    PriceSuggestions.Request,
    Interest,
    Interests,
    Repo
  }

  import Re.Factory

  import Mockery

  describe "request_price_suggestion/2" do
    test "should store price suggestion request" do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":1342.0,\"sale_price\":1342.213,\"listing_price_rounded\":1565.0,\"listing_price\":1565.654}"
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

      assert {:ok, %{id: request_id, suggested_price: 1565.0}} =
               Interests.request_price_suggestion(params, nil)

      assert request = Repo.get(Request, request_id)
      assert request.suggested_price == 1565.0
    end

    test "should store price suggestion request with user attached" do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":1342.0,\"sale_price\":1342.213,\"listing_price_rounded\":1565.0,\"listing_price\":1565.654}"
         }}
      )

      user = insert(:user)

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

      assert {:ok, %{id: request_id, suggested_price: 1565.0}} =
               Interests.request_price_suggestion(params, user)

      assert request = Repo.get(Request, request_id)
      assert request.user_id == user.id
      assert request.suggested_price == 1565.0
    end

    test "should store price suggestion request when street is not covered" do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":1342.0,\"sale_price\":1342.213,\"listing_price_rounded\":1565.0,\"listing_price\":1565.654}"
         }}
      )

      address_params = %{
        street: "not covered street",
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

      assert {:ok, %{id: request_id, suggested_price: 1565.0}} =
               Interests.request_price_suggestion(params, nil)

      assert request = Repo.get(Request, request_id)
      assert request.suggested_price == 1565.0
    end
  end

  describe "notify_when_covered/1" do
    test "should request notification for address with user" do
      {:ok, notify_when_covered} =
        Interests.notify_when_covered(%{
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
      {:error, changeset} = Interests.notify_when_covered(%{})

      assert [
               state: {"can't be blank", [validation: :required]},
               city: {"can't be blank", [validation: :required]},
               neighborhood: {"can't be blank", [validation: :required]}
             ] == changeset.errors
    end
  end

  describe "show_interest/1" do
    test "should create interest in listing" do
      Re.PubSub.subscribe("new_interest")
      listing = insert(:listing)

      {:ok, interest} =
        Interests.show_interest(%{
          name: "naem",
          phone: "123",
          interest_type: 2,
          listing_id: listing.id
        })

      assert interest = Repo.get(Interest, interest.id)
      assert interest.uuid
      assert_receive %{new: _, topic: "new_interest", type: :new}
      assert Repo.one(JobQueue)
    end

    test "should not create interest in invalid listing" do
      Re.PubSub.subscribe("new_interest")

      {:error, :add_interest, _, _} =
        Interests.show_interest(%{name: "naem", phone: "123", interest_type: 2, listing_id: -1})

      refute_receive %{new: _, topic: "new_interest", type: :new}
    end
  end
end
