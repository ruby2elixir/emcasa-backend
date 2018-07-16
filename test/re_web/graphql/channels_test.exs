defmodule ReWeb.GraphQL.ChannelsTest do
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
    test "admin should list its channels", %{admin_conn: conn, admin_user: admin_user} do
      user = insert(:user)
      admin2 = insert(:user, role: "admin")
      listing = insert(:listing)
      listing2 = insert(:listing)

      insert(
        :channel,
        participant1_id: admin_user.id,
        participant2_id: user.id,
        listing_id: listing2.id
      )

      insert(:channel, participant1_id: admin2.id, participant2_id: user.id)

      channel =
        insert(
          :channel,
          listing_id: listing.id,
          participant1_id: admin_user.id,
          participant2_id: user.id
        )

      m1 =
        insert(
          :message,
          channel_id: channel.id,
          sender_id: admin_user.id,
          receiver_id: user.id,
          listing_id: listing.id,
          read: true
        )

      m2 =
        insert(
          :message,
          channel_id: channel.id,
          sender_id: user.id,
          receiver_id: admin_user.id,
          listing_id: listing.id,
          read: false
        )

      query = """
        {
          userChannels (
            listingId: #{listing.id},
            otherParticipantId: #{admin_user.id}
          ) {
            id
            participant1 { id }
            participant2 { id }
            listing { id }
            unreadCount
            messages { id }
            lastMessage: messages (limit: 1) {
              id
            }
            subsequentMessage: messages(offset: 1) {
              id
            }
          }
        }
      """

      channel_id = to_string(channel.id)
      m1_id = to_string(m1.id)
      m2_id = to_string(m2.id)
      user_id1 = to_string(admin_user.id)
      user_id2 = to_string(user.id)
      listing_id = to_string(listing.id)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listingUserMessages"))

      assert [
               %{
                 "id" => channel_id,
                 "participant1" => %{"id" => user_id1},
                 "participant2" => %{"id" => user_id2},
                 "listing" => %{"id" => listing_id},
                 "unreadCount" => 1,
                 "messages" => [
                   %{"id" => m2_id},
                   %{"id" => m1_id}
                 ],
                 "lastMessage" => [%{"id" => m2_id}],
                 "subsequentMessage" => [%{"id" => m1_id}]
               }
             ] == json_response(conn, 200)["data"]["userChannels"]
    end
  end
end
