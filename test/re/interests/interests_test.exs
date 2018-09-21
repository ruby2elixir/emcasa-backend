defmodule Re.InterestsTest do
  use Re.ModelCase

  alias Re.{
    PriceSuggestions.Request,
    Interests,
    Repo
  }

  import Re.Factory

  describe "request_price_suggestion/2" do
    test "should store price suggestion request" do
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

      assert Repo.get(Request, request_id)
    end

    test "should store price suggestion request with user attached" do
      insert(
        :factors,
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

      assert Repo.get(Request, request_id)
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

      assert Repo.get(Request, request_id)
    end
  end

  describe "notify_when_covered/1" do
    test "should request notification for address with user" do
      %{id: address_id} = insert(:address)
      user = insert(:user)

      {:ok, notify_when_covered} =
        Interests.notify_when_covered(
          %{
            address_id: address_id,
            name: "naem",
            phone: "1920381",
            email: "user@emcasa.com",
            message: "message"
          },
          user
        )

      assert address_id == notify_when_covered.address_id
      assert "naem" == notify_when_covered.name
      assert "1920381" == notify_when_covered.phone
      assert "user@emcasa.com" == notify_when_covered.email
      assert "message" == notify_when_covered.message
    end

    test "should request notification without user" do
      %{id: address_id} = insert(:address)

      {:ok, notify_when_covered} =
        Interests.notify_when_covered(
          %{
            address_id: address_id,
            name: "naem",
            phone: "1920381",
            email: "user@emcasa.com",
            message: "message"
          },
          nil
        )

      assert address_id == notify_when_covered.address_id
      assert "naem" == notify_when_covered.name
      assert "1920381" == notify_when_covered.phone
      assert "user@emcasa.com" == notify_when_covered.email
      assert "message" == notify_when_covered.message
      refute notify_when_covered.user_id
    end

    test "should not request notification without address" do
      {:error, changeset} = Interests.notify_when_covered(%{})

      assert [address_id: {"can't be blank", [validation: :required]}] == changeset.errors
    end
  end
end
