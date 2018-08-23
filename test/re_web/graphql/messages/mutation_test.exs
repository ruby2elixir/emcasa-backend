defmodule ReWeb.GraphQL.Messages.MutationTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  alias Re.{
    Message,
    Repo
  }

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_user: admin_user,
     user_user: user_user,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  describe "sendMessage" do
    test "admin should send messages", %{admin_conn: conn, admin_user: admin} do
      user = insert(:user)
      listing = insert(:listing)

      variables = %{
        "receiverId" => user.id,
        "listingId" => listing.id
      }

      mutation = """
        mutation SendMessage($receiverId: ID!, $listingId: ID!) {
          sendMessage (receiverId: $receiverId, listingId: $listingId){
            sender {
              id
            }
            receiver {
              id
            }
            listing {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      admin_id = to_string(admin.id)
      user_id = to_string(user.id)
      listing_id = to_string(listing.id)

      assert %{
               "sendMessage" => %{
                 "sender" => %{"id" => ^admin_id},
                 "receiver" => %{"id" => ^user_id},
                 "listing" => %{"id" => ^listing_id}
               }
             } = json_response(conn, 200)["data"]
    end

    test "user should send messages", %{user_conn: conn, user_user: user} do
      user2 = insert(:user)
      listing = insert(:listing)

      variables = %{
        "receiverId" => user2.id,
        "listingId" => listing.id
      }

      mutation = """
        mutation SendMessage($receiverId: ID!, $listingId: ID!) {
          sendMessage (receiverId: $receiverId, listingId: $listingId){
            sender {
              id
            }
            receiver {
              id
            }
            listing {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      user_id = to_string(user.id)
      user2_id = to_string(user2.id)
      listing_id = to_string(listing.id)

      assert %{
               "sendMessage" => %{
                 "sender" => %{"id" => ^user_id},
                 "receiver" => %{"id" => ^user2_id},
                 "listing" => %{"id" => ^listing_id}
               }
             } = json_response(conn, 200)["data"]
    end

    test "anonymous should not send messages", %{unauthenticated_conn: conn} do
      user = insert(:user)
      listing = insert(:listing)

      variables = %{
        "receiverId" => user.id,
        "listingId" => listing.id
      }

      mutation = """
        mutation SendMessage($receiverId: ID!, $listingId: ID!) {
          sendMessage (receiverId: $receiverId, listingId: $listingId){
            sender {
              id
            }
            receiver {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{"errors" => [%{"message" => "Unauthorized", "code" => 401}]} =
               json_response(conn, 200)
    end
  end

  describe "markAsRead" do
    test "owner can mark received messages as read", %{
      user_conn: conn,
      user_user: user,
      admin_user: admin_user
    } do
      listing = insert(:listing)

      %{id: message_id1} =
        insert(
          :message,
          sender_id: admin_user.id,
          receiver_id: user.id,
          listing_id: listing.id,
          read: false,
          channel: build(:channel)
        )

      %{id: message_id2} =
        insert(
          :message,
          sender_id: admin_user.id,
          receiver_id: user.id,
          listing_id: listing.id,
          read: false,
          channel: build(:channel)
        )

      variables = %{
        "id1" => message_id1,
        "id2" => message_id2
      }

      mutation = """
        mutation MarkAsRead($id1: ID!, $id2: ID!) {
          markAsRead1: markAsRead (id: $id1){
            id
            sender {
              id
            }
            receiver {
              id
            }
            listing {
              id
            }
            read
          }
          markAsRead2: markAsRead (id: $id2){
            id
            sender {
              id
            }
            receiver {
              id
            }
            listing {
              id
            }
            read
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      admin_id = to_string(admin_user.id)
      user_id = to_string(user.id)
      listing_id = to_string(listing.id)
      message_id1 = to_string(message_id1)
      message_id2 = to_string(message_id2)

      assert %{
               "markAsRead1" => %{
                 "id" => ^message_id1,
                 "sender" => %{"id" => ^admin_id},
                 "receiver" => %{"id" => ^user_id},
                 "listing" => %{"id" => ^listing_id},
                 "read" => true
               },
               "markAsRead2" => %{
                 "id" => ^message_id2,
                 "sender" => %{"id" => ^admin_id},
                 "receiver" => %{"id" => ^user_id},
                 "listing" => %{"id" => ^listing_id},
                 "read" => true
               }
             } = json_response(conn, 200)["data"]

      assert Repo.get(Message, message_id1).read
      assert Repo.get(Message, message_id2).read
    end

    test "owner cannot mark sent messages as read", %{
      user_conn: conn,
      user_user: user,
      admin_user: admin_user
    } do
      listing = insert(:listing)

      %{id: message_id1} =
        insert(
          :message,
          sender_id: user.id,
          receiver_id: admin_user.id,
          listing_id: listing.id,
          read: false,
          channel: build(:channel)
        )

      %{id: message_id2} =
        insert(
          :message,
          sender_id: user.id,
          receiver_id: admin_user.id,
          listing_id: listing.id,
          read: false,
          channel: build(:channel)
        )

      variables = %{
        "id1" => message_id1,
        "id2" => message_id2
      }

      mutation = """
        mutation MarkAsRead($id1: ID!, $id2: ID!) {
          markAsRead1: markAsRead (id: $id1){
            id
            sender {
              id
            }
            receiver {
              id
            }
            listing {
              id
            }
            read
          }
          markAsRead2: markAsRead (id: $id2){
            id
            sender {
              id
            }
            receiver {
              id
            }
            listing {
              id
            }
            read
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "errors" => [
                 %{"message" => "Forbidden", "code" => 403},
                 %{"message" => "Forbidden", "code" => 403}
               ]
             } = json_response(conn, 200)

      refute Repo.get(Message, message_id1).read
      refute Repo.get(Message, message_id2).read
    end

    test "admin can mark received messages as read", %{
      admin_conn: conn,
      user_user: user,
      admin_user: admin_user
    } do
      listing = insert(:listing)

      %{id: message_id1} =
        insert(
          :message,
          sender_id: user.id,
          receiver_id: admin_user.id,
          listing_id: listing.id,
          read: false,
          channel: build(:channel)
        )

      %{id: message_id2} =
        insert(
          :message,
          sender_id: user.id,
          receiver_id: admin_user.id,
          listing_id: listing.id,
          read: false,
          channel: build(:channel)
        )

      variables = %{
        "id1" => message_id1,
        "id2" => message_id2
      }

      mutation = """
        mutation MarkAsRead($id1: ID!, $id2: ID!) {
          markAsRead1: markAsRead (id: $id1){
            id
            sender {
              id
            }
            receiver {
              id
            }
            listing {
              id
            }
            read
          }
          markAsRead2: markAsRead (id: $id2){
            id
            sender {
              id
            }
            receiver {
              id
            }
            listing {
              id
            }
            read
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      admin_id = to_string(admin_user.id)
      user_id = to_string(user.id)
      listing_id = to_string(listing.id)
      message_id1 = to_string(message_id1)
      message_id2 = to_string(message_id2)

      assert %{
               "markAsRead1" => %{
                 "id" => ^message_id1,
                 "sender" => %{"id" => ^user_id},
                 "receiver" => %{"id" => ^admin_id},
                 "listing" => %{"id" => ^listing_id},
                 "read" => true
               },
               "markAsRead2" => %{
                 "id" => ^message_id2,
                 "sender" => %{"id" => ^user_id},
                 "receiver" => %{"id" => ^admin_id},
                 "listing" => %{"id" => ^listing_id},
                 "read" => true
               }
             } = json_response(conn, 200)["data"]

      assert Repo.get(Message, message_id1).read
      assert Repo.get(Message, message_id2).read
    end

    test "admin cannot mark sent messages as read", %{
      admin_conn: conn,
      user_user: user,
      admin_user: admin_user
    } do
      listing = insert(:listing)

      %{id: message_id1} =
        insert(
          :message,
          sender_id: admin_user.id,
          receiver_id: user.id,
          listing_id: listing.id,
          read: false,
          channel: build(:channel)
        )

      %{id: message_id2} =
        insert(
          :message,
          sender_id: admin_user.id,
          receiver_id: user.id,
          listing_id: listing.id,
          read: false,
          channel: build(:channel)
        )

      variables = %{
        "id1" => message_id1,
        "id2" => message_id2
      }

      mutation = """
        mutation MarkAsRead($id1: ID!, $id2: ID!) {
          markAsRead1: markAsRead (id: $id1){
            id
            sender {
              id
            }
            receiver {
              id
            }
            listing {
              id
            }
            read
          }
          markAsRead2: markAsRead (id: $id2){
            id
            sender {
              id
            }
            receiver {
              id
            }
            listing {
              id
            }
            read
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "errors" => [
                 %{"message" => "Forbidden", "code" => 403},
                 %{"message" => "Forbidden", "code" => 403}
               ]
             } = json_response(conn, 200)

      refute Repo.get(Message, message_id1).read
      refute Repo.get(Message, message_id2).read
    end

    test "anonymous cannot mark any messages as read", %{
      unauthenticated_conn: conn,
      user_user: user,
      admin_user: admin_user
    } do
      listing = insert(:listing)

      %{id: message_id1} =
        insert(
          :message,
          sender_id: admin_user.id,
          receiver_id: user.id,
          listing_id: listing.id,
          read: false,
          channel: build(:channel)
        )

      %{id: message_id2} =
        insert(
          :message,
          sender_id: user.id,
          receiver_id: admin_user.id,
          listing_id: listing.id,
          read: false,
          channel: build(:channel)
        )

      variables = %{
        "id1" => message_id1,
        "id2" => message_id2
      }

      mutation = """
        mutation MarkAsRead($id1: ID!, $id2: ID!) {
          markAsRead1: markAsRead (id: $id1){
            id
            sender {
              id
            }
            receiver {
              id
            }
            listing {
              id
            }
            read
          }
          markAsRead2: markAsRead (id: $id2){
            id
            sender {
              id
            }
            receiver {
              id
            }
            listing {
              id
            }
            read
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "errors" => [
                 %{"message" => "Forbidden", "code" => 403},
                 %{"message" => "Forbidden", "code" => 403}
               ]
             } = json_response(conn, 200)

      refute Repo.get(Message, message_id1).read
      refute Repo.get(Message, message_id2).read
    end
  end
end
