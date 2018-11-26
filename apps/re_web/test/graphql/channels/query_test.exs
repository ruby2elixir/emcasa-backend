defmodule ReWeb.GraphQL.Channels.QueryTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

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

  describe "userChannels" do
    test "admin should list its channels per listing and user", %{
      admin_conn: conn,
      admin_user: admin_user,
      user_user: user
    } do
      listing1 = insert(:listing)
      listing2 = insert(:listing)

      %{
        channel: %{id: c1_id},
        messages: [%{id: m1c1_id}, %{id: m2c1_id}, %{id: m3c1_id}, %{id: m4c1_id}]
      } = insert_channel_and_messages(listing1.id, user.id, admin_user.id)

      insert_channel_and_messages(listing2.id, user.id, admin_user.id)

      variables = %{
        "listingId" => listing1.id,
        "otherParticipantId" => admin_user.id
      }

      query = """
        query UserChannels($listingId: ID, $otherParticipantId: ID) {
          userChannels (listingId: $listingId, otherParticipantId: $otherParticipantId) {
            id
            participant1 { id }
            participant2 { id }
            listing { id }
            unreadCount
            messages { id }
            lastMessage: messages (limit: 1) {
              id
            }
            subsequentMessage: messages(limit: 1, offset: 1) {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert [
               %{
                 "id" => to_string(c1_id),
                 "participant1" => %{"id" => to_string(admin_user.id)},
                 "participant2" => %{"id" => to_string(user.id)},
                 "listing" => %{"id" => to_string(listing1.id)},
                 "unreadCount" => 1,
                 "messages" => [
                   %{"id" => to_string(m4c1_id)},
                   %{"id" => to_string(m3c1_id)},
                   %{"id" => to_string(m2c1_id)},
                   %{"id" => to_string(m1c1_id)}
                 ],
                 "lastMessage" => [%{"id" => to_string(m4c1_id)}],
                 "subsequentMessage" => [%{"id" => to_string(m3c1_id)}]
               }
             ] == json_response(conn, 200)["data"]["userChannels"]
    end

    test "admin should list its channels", %{
      admin_conn: conn,
      admin_user: admin_user,
      user_user: user
    } do
      listing1 = insert(:listing)
      listing2 = insert(:listing)

      %{
        channel: %{id: c1_id},
        messages: [%{id: m1c1_id}, %{id: m2c1_id}, %{id: m3c1_id}, %{id: m4c1_id}]
      } = insert_channel_and_messages(listing1.id, user.id, admin_user.id)

      %{
        channel: %{id: c2_id},
        messages: [%{id: m1c2_id}, %{id: m2c2_id}, %{id: m3c2_id}, %{id: m4c2_id}]
      } = insert_channel_and_messages(listing2.id, user.id, admin_user.id)

      query = """
        query UserChannels {
          userChannels {
            id
            participant1 { id }
            participant2 { id }
            listing { id }
            unreadCount
            messages { id }
            lastMessage: messages (limit: 1) {
              id
            }
            subsequentMessage: messages(limit: 1, offset: 1) {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert [
               %{
                 "id" => to_string(c2_id),
                 "participant1" => %{"id" => to_string(admin_user.id)},
                 "participant2" => %{"id" => to_string(user.id)},
                 "listing" => %{"id" => to_string(listing2.id)},
                 "unreadCount" => 1,
                 "messages" => [
                   %{"id" => to_string(m4c2_id)},
                   %{"id" => to_string(m3c2_id)},
                   %{"id" => to_string(m2c2_id)},
                   %{"id" => to_string(m1c2_id)}
                 ],
                 "lastMessage" => [%{"id" => to_string(m4c2_id)}],
                 "subsequentMessage" => [%{"id" => to_string(m3c2_id)}]
               },
               %{
                 "id" => to_string(c1_id),
                 "participant1" => %{"id" => to_string(admin_user.id)},
                 "participant2" => %{"id" => to_string(user.id)},
                 "listing" => %{"id" => to_string(listing1.id)},
                 "unreadCount" => 1,
                 "messages" => [
                   %{"id" => to_string(m4c1_id)},
                   %{"id" => to_string(m3c1_id)},
                   %{"id" => to_string(m2c1_id)},
                   %{"id" => to_string(m1c1_id)}
                 ],
                 "lastMessage" => [%{"id" => to_string(m4c1_id)}],
                 "subsequentMessage" => [%{"id" => to_string(m3c1_id)}]
               }
             ] == json_response(conn, 200)["data"]["userChannels"]
    end
  end

  test "user should list its channels", %{
    user_conn: conn,
    admin_user: admin_user,
    user_user: user
  } do
    listing1 = insert(:listing)
    listing2 = insert(:listing)

    %{
      channel: %{id: c1_id},
      messages: [%{id: m1c1_id}, %{id: m2c1_id}, %{id: m3c1_id}, %{id: m4c1_id}]
    } = insert_channel_and_messages(listing1.id, user.id, admin_user.id)

    %{
      channel: %{id: c2_id},
      messages: [%{id: m1c2_id}, %{id: m2c2_id}, %{id: m3c2_id}, %{id: m4c2_id}]
    } = insert_channel_and_messages(listing2.id, user.id, admin_user.id)

    query = """
      query UserChannels {
        userChannels {
          id
          participant1 { id }
          participant2 { id }
          listing { id }
          unreadCount
          messages { id }
          lastMessage: messages (limit: 1) {
            id
          }
          subsequentMessage: messages(limit: 1, offset: 1) {
            id
          }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert [
             %{
               "id" => to_string(c2_id),
               "participant1" => %{"id" => to_string(admin_user.id)},
               "participant2" => %{"id" => to_string(user.id)},
               "listing" => %{"id" => to_string(listing2.id)},
               "unreadCount" => 1,
               "messages" => [
                 %{"id" => to_string(m4c2_id)},
                 %{"id" => to_string(m3c2_id)},
                 %{"id" => to_string(m2c2_id)},
                 %{"id" => to_string(m1c2_id)}
               ],
               "lastMessage" => [%{"id" => to_string(m4c2_id)}],
               "subsequentMessage" => [%{"id" => to_string(m3c2_id)}]
             },
             %{
               "id" => to_string(c1_id),
               "participant1" => %{"id" => to_string(admin_user.id)},
               "participant2" => %{"id" => to_string(user.id)},
               "listing" => %{"id" => to_string(listing1.id)},
               "unreadCount" => 1,
               "messages" => [
                 %{"id" => to_string(m4c1_id)},
                 %{"id" => to_string(m3c1_id)},
                 %{"id" => to_string(m2c1_id)},
                 %{"id" => to_string(m1c1_id)}
               ],
               "lastMessage" => [%{"id" => to_string(m4c1_id)}],
               "subsequentMessage" => [%{"id" => to_string(m3c1_id)}]
             }
           ] == json_response(conn, 200)["data"]["userChannels"]
  end

  test "anonymous should not list channels", %{unauthenticated_conn: conn} do
    query = """
      query UserChannels {
        userChannels {
          id
          participant1 { id }
          participant2 { id }
          listing { id }
          unreadCount
          messages { id }
          lastMessage: messages (limit: 1) {
            id
          }
          subsequentMessage: messages(limit: 1, offset: 1) {
            id
          }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert %{"errors" => [%{"message" => "Unauthorized", "code" => 401}]} =
             json_response(conn, 200)
  end

  test "should count unread messages", %{
    admin_conn: conn,
    admin_user: admin_user,
    user_user: user
  } do
    listing1 = insert(:listing)
    listing2 = insert(:listing)

    %{channel: %{id: c1_id}} = insert_channel_and_messages(listing1.id, user.id, admin_user.id)
    %{channel: %{id: c2_id}} = insert_channel_and_messages(listing2.id, user.id, admin_user.id)

    query = """
      query UserChannels {
        userChannels {
          id
          unreadCount
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert [
             %{
               "id" => to_string(c2_id),
               "unreadCount" => 1
             },
             %{
               "id" => to_string(c1_id),
               "unreadCount" => 1
             }
           ] == json_response(conn, 200)["data"]["userChannels"]
  end

  defp insert_channel_and_messages(listing_id, user1_id, user2_id) do
    %{id: channel_id} =
      channel =
      insert(
        :channel,
        listing_id: listing_id,
        participant1_id: user2_id,
        participant2_id: user1_id
      )

    message1 =
      insert(
        :message,
        channel_id: channel_id,
        sender_id: user2_id,
        receiver_id: user1_id,
        listing_id: listing_id,
        read: true
      )

    message2 =
      insert(
        :message,
        channel_id: channel_id,
        sender_id: user1_id,
        receiver_id: user2_id,
        listing_id: listing_id,
        read: false
      )

    message3 =
      insert(
        :message,
        channel_id: channel_id,
        sender_id: user2_id,
        receiver_id: user1_id,
        listing_id: listing_id,
        read: false
      )

    message4 =
      insert(
        :message,
        channel_id: channel_id,
        sender_id: user1_id,
        receiver_id: user2_id,
        listing_id: listing_id,
        read: true
      )

    %{channel: channel, messages: [message1, message2, message3, message4]}
  end

  test "should list channel when listing is deactivated", %{
    user_conn: conn,
    admin_user: admin_user,
    user_user: user
  } do
    listing1 = insert(:listing, status: "inactive")
    listing2 = insert(:listing)

    insert_channel_and_messages(listing1.id, user.id, admin_user.id)
    insert_channel_and_messages(listing2.id, user.id, admin_user.id)

    query = """
      query UserChannels {
        userChannels {
          listing { id }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert [
             %{"listing" => %{"id" => to_string(listing2.id)}},
             %{"listing" => %{"id" => to_string(listing1.id)}}
           ] == json_response(conn, 200)["data"]["userChannels"]
  end
end
