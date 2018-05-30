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
      listing = insert(:listing)

      channel = insert(:channel, listing_id: listing.id, participant1_id: admin_user.id, participant2_id: user.id)

      insert(:message, channel_id: channel.id, sender_id: admin_user.id, receiver_id: user.id, listing_id: listing.id)
      m1 = insert(:message, channel_id: channel.id, sender_id: user.id, receiver_id: admin_user.id, listing_id: listing.id)

      query = """
        {
          userChannels {
            id
            participant1 { id }
            participant2 { id }
            listing { id }
            messages { id }
          }
        }
      """

      channel_id = to_string(channel.id)
      m1_id = to_string(m1.id)
      user_id1 = to_string(admin_user.id)
      user_id2 = to_string(user.id)
      listing_id = to_string(listing.id)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listingUserMessages"))

      assert %{
               "userChannels" => [%{
                 "id" => ^channel_id,
                 "participant1" => %{"id" => ^user_id1},
                 "participant2" => %{"id" => ^user_id2},
                 "listing" => %{"id" => ^listing_id},
                 "messages" => [
                   %{"id" => ^m1_id}
                 ]
               }]
             } = json_response(conn, 200)["data"]
    end
  end
end
