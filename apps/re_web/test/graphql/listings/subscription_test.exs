defmodule ReWeb.GraphQL.Listings.SubscriptionTest do
  use ReWeb.SubscriptionCase

  @subscriptions [
    {"""
     subscription {
       listingUpdated {
         id
         type
       }
     }
     """, "listingUpdated", "updateListing"}
  ]

  import Re.Factory

  Enum.each(@subscriptions, fn {subscription, subscription_name, mutation} ->
    @subscription subscription
    @subscription_name subscription_name
    @mutation mutation

    test "admin should subscribe to #{@mutation}", %{
      admin_socket: admin_socket
    } do
      ref = push_doc(admin_socket, @subscription)
      %{id: address_id} = insert(:address)
      listing = insert(:listing, type: "Apartamento", address_id: address_id)

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      mutation = """
        mutation {
          #{@mutation}(
          id: #{listing.id},
          input: {
            type: "Casa",
            addressId: #{address_id}
          }) {
            id
            type
          }
        }
      """

      ref = push_doc(admin_socket, mutation)

      assert_reply(
        ref,
        :ok,
        %{data: %{@mutation => %{"id" => listing_id, "type" => "Casa"}}},
        3000
      )

      expected = %{
        result: %{
          data: %{
            @subscription_name => %{"id" => listing_id, "type" => "Casa"}
          }
        },
        subscriptionId: subscription_id
      }

      assert_push("subscription:data", push)
      assert expected == push
    end

    test "user should not subscribe to #{@mutation}", %{
      user_socket: user_socket
    } do
      ref = push_doc(user_socket, @subscription)

      assert_reply(ref, :error, %{errors: [%{message: :unauthorized}]})
    end

    test "anonymous should not subscribe to #{@mutation}", %{
      unauthenticated_socket: unauthenticated_socket
    } do
      ref = push_doc(unauthenticated_socket, @subscription)

      assert_reply(ref, :error, %{errors: [%{message: :unauthenticated}]})
    end
  end)
end