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

  describe "request_price_suggestion/2" do
    test "should store price suggestion request" do
      insert(
        :factors,
        state: "ST",
        city: "city",
        street: "street",
        intercept: 10.10,
        rooms: 123.321,
        area: 321.123,
        bathrooms: 111.222,
        garage_spots: 222.111
      )

      address_params = %{
        street: "street",
        street_number: "street_number",
        neighborhood: "neighborhood",
        city: "city",
        state: "ST",
        postal_code: "postal_code",
        lat: 10.10,
        lng: 10.10
      }

      params = %{
        address: address_params,
        name: "name",
        email: "email@emcasa.com",
        rooms: 2,
        bathrooms: 2,
        area: 2,
        garage_spots: 2,
        is_covered: true
      }

      assert {:ok, %{id: request_id}, {:ok, 1565.654}} =
               Interests.request_price_suggestion(params, nil)

      assert request = Repo.get(Request, request_id)
      assert request.suggested_price == 1565.654
    end

    test "should store price suggestion request with user attached" do
      insert(
        :factors,
        state: "ST",
        city: "city",
        street: "street",
        intercept: 10.10,
        rooms: 123.321,
        area: 321.123,
        bathrooms: 111.222,
        garage_spots: 222.111
      )

      user = insert(:user)

      address_params = %{
        street: "street",
        street_number: "street_number",
        neighborhood: "neighborhood",
        city: "city",
        state: "ST",
        postal_code: "postal_code",
        lat: 10.10,
        lng: 10.10
      }

      params = %{
        address: address_params,
        name: "name",
        email: "email@emcasa.com",
        rooms: 2,
        bathrooms: 2,
        area: 2,
        garage_spots: 2,
        is_covered: true
      }

      assert {:ok, %{id: request_id}, {:ok, 1565.654}} =
               Interests.request_price_suggestion(params, user)

      assert request = Repo.get(Request, request_id)
      assert request.user_id == user.id
      assert request.suggested_price == 1565.654
    end

    test "should store price suggestion request when street is not covered" do
      insert(
        :factors,
        street: "street",
        intercept: 10.10,
        rooms: 123.321,
        area: 321.123,
        bathrooms: 111.222,
        garage_spots: 222.111
      )

      address_params = %{
        street: "not covered street",
        street_number: "street_number",
        neighborhood: "neighborhood",
        city: "city",
        state: "ST",
        postal_code: "postal_code",
        lat: 10.10,
        lng: 10.10
      }

      params = %{
        address: address_params,
        name: "name",
        email: "email@emcasa.com",
        rooms: 2,
        bathrooms: 2,
        area: 2,
        garage_spots: 2,
        is_covered: false
      }

      assert {:ok, %{id: request_id}, {:error, :street_not_covered}} =
               Interests.request_price_suggestion(params, nil)

      assert request = Repo.get(Request, request_id)
      refute request.suggested_price
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
