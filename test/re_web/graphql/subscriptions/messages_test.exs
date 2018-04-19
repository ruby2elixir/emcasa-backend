defmodule ReWeb.GraphQL.Subscription.MessagesTest do
  use ReWeb.SubscriptionCase

  @subscription """
    subscription {
      messageSent {
        sender {
          id
        }
        receiver {
          id
        }
        message
      }
    }
  """

  import Re.Factory

  test "user should subscribe to own messages", %{
    user_socket: user_socket,
    user_user: user_user,
    admin_user: admin_user,
    admin_socket: admin_socket
  } do
    ref = push_doc(user_socket, @subscription)
    user_id = to_string(user_user.id)
    admin_id = to_string(admin_user.id)

    assert_reply(ref, :ok, %{subscriptionId: subscription_id})

    mutation = """
      mutation {
        sendMessage(receiverId: #{user_id}, message: "mah message") {
          sender {
            id
          }
          receiver {
            id
          }
        }
      }
    """

    ref = push_doc(admin_socket, mutation)

    assert_reply(
      ref,
      :ok,
      %{data: %{"sendMessage" => %{"receiver" => %{"id" => ^user_id}}}},
      3000
    )

    expected = %{
      result: %{
        data: %{
          "messageSent" => %{
            "message" => "mah message",
            "receiver" => %{"id" => user_id},
            "sender" => %{"id" => admin_id}
          }
        }
      },
      subscriptionId: subscription_id
    }

    assert_push("subscription:data", push)
    assert expected == push
  end

  test "admin should subscribe to own messages", %{
    user_socket: user_socket,
    user_user: user_user,
    admin_user: admin_user,
    admin_socket: admin_socket
  } do
    ref = push_doc(admin_socket, @subscription)
    user_id = to_string(user_user.id)
    admin_id = to_string(admin_user.id)

    assert_reply(ref, :ok, %{subscriptionId: subscription_id})

    mutation = """
      mutation {
        sendMessage(receiverId: #{admin_id}, message: "mah message") {
          sender {
            id
          }
          receiver {
            id
          }
        }
      }
    """

    ref = push_doc(user_socket, mutation)

    assert_reply(
      ref,
      :ok,
      %{data: %{"sendMessage" => %{"receiver" => %{"id" => ^admin_id}}}},
      3000
    )

    expected = %{
      result: %{
        data: %{
          "messageSent" => %{
            "message" => "mah message",
            "receiver" => %{"id" => admin_id},
            "sender" => %{"id" => user_id}
          }
        }
      },
      subscriptionId: subscription_id
    }

    assert_push("subscription:data", push)
    assert expected == push
  end

  test "anonymous should not subscribe to messages", %{unauthenticated_socket: unauthenticated_socket} do
    ref = push_doc(unauthenticated_socket, @subscription)

    assert_reply(ref, :error, %{errors: [%{message: :unauthenticated}]})
  end
end
