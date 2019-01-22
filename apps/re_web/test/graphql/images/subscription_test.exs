defmodule ReWeb.GraphQL.Images.SubscriptionTest do
  use ReWeb.SubscriptionCase

  @activation_subscriptions [
    {"""
     subscription {
       imagesDeactivated {
         id
       }
     }
     """, "imagesDeactivated", "imagesDeactivate"}
  ]

  @update_subscriptions [
    {"""
     subscription {
       imagesUpdated {
         id
         position
         description
       }
     }
     """, "imagesUpdated", "updateImages"}
  ]

  import Re.Factory

  Enum.each(@activation_subscriptions, fn {subscription, subscription_name, mutation} ->
    @subscription subscription
    @subscription_name subscription_name
    @mutation mutation

    test "admin should subscribe to #{@mutation}", %{
      admin_socket: admin_socket
    } do
      ref = push_doc(admin_socket, @subscription)
      %{id: listing_id} = insert(:listing)

      [%{id: id1}, %{id: id2}, %{id: id3}] =
        insert_list(
          3,
          :image,
          listing_id: listing_id,
          position: 5,
          description: "wah",
          filename: "test.jpg",
          is_active: true
        )

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      mutation = """
        mutation {
          #{@mutation}(input: {
            imageIds: [#{id1},#{id2},#{id3}]
          }) {
            id
          }
        }
      """

      ref = push_doc(admin_socket, mutation)

      assert_reply(
        ref,
        :ok,
        %{data: %{@mutation => [
          %{"id" => id1},
          %{"id" => id2},
          %{"id" => id3},
          ]}},
        3000
      )

      expected = %{
        result: %{
          data: %{
            @subscription_name => [
              %{"id" => id1},
              %{"id" => id2},
              %{"id" => id3}
            ]
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

  Enum.each(@update_subscriptions, fn {subscription, subscription_name, mutation} ->
    @subscription subscription
    @subscription_name subscription_name
    @mutation mutation

    test "admin should subscribe to #{@mutation}", %{
      admin_socket: admin_socket
    } do
      ref = push_doc(admin_socket, @subscription)
      %{id: listing_id} = insert(:listing)

      [%{id: id1}, %{id: id2}, %{id: id3}] =
        insert_list(
          3,
          :image,
          listing_id: listing_id,
          position: 5,
          description: "wah1",
          filename: "test.jpg",
          is_active: true
        )

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      mutation = """
        mutation {
          #{@mutation}(input: [
            {id: #{id1}, position: 4, description: "wah2"},
            {id: #{id2}, position: 4, description: "wah2"},
            {id: #{id3}, position: 4, description: "wah2"}
          ]) {
            id
            position
            description
          }
        }
      """

      ref = push_doc(admin_socket, mutation)

      assert_reply(
        ref,
        :ok,
        %{data: %{@mutation => [
          %{"id" => id1, "position" => 4, "description" => "wah2"},
          %{"id" => id2, "position" => 4, "description" => "wah2"},
          %{"id" => id3, "position" => 4, "description" => "wah2"},
          ]}},
        3000
      )

      expected = %{
        result: %{
          data: %{
            @subscription_name => [
              %{"id" => id1, "position" => 4, "description" => "wah2"},
              %{"id" => id2, "position" => 4, "description" => "wah2"},
              %{"id" => id3, "position" => 4, "description" => "wah2"}
            ]
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
