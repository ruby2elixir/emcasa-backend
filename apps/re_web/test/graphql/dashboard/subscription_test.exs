defmodule ReWeb.GraphQL.Dashboard.SubscriptionTest do
  use ReWeb.SubscriptionCase

  @subscriptions [
    {"""
     subscription {
       listingHighlightedZap {
         id
       }
     }
     """, "listingHighlightedZap", "listingHighlightZap"},
    {"""
     subscription {
       listingSuperHighlightedZap {
         id
       }
     }
     """, "listingSuperHighlightedZap", "listingSuperHighlightZap"},
    {"""
     subscription {
       listingHighlightedVivareal {
         id
       }
     }
     """, "listingHighlightedVivareal", "listingHighlightVivareal"}
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
      listing = insert(:listing)

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      mutation = """
        mutation {
          #{@mutation}(listingId: #{listing.id}) {
            id
          }
        }
      """

      ref = push_doc(admin_socket, mutation)

      assert_reply(
        ref,
        :ok,
        %{data: %{@mutation => %{"id" => listing_id}}},
        3000
      )

      expected = %{
        result: %{
          data: %{
            @subscription_name => %{
              "id" => listing_id
            }
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
