defmodule ReWeb.GraphQL.MessagesTest do
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

  describe "sendMessage" do
    test "admin should send messages", %{admin_conn: conn, admin_user: admin} do
      user = insert(:user)

      mutation = """
        mutation {
          sendMessage (receiverId: #{user.id}){
            sender {
              id
            }
            receiver {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      admin_id = to_string(admin.id)
      user_id = to_string(user.id)

      assert %{
               "sendMessage" => %{
                 "sender" => %{"id" => ^admin_id},
                 "receiver" => %{"id" => ^user_id}
               }
             } = json_response(conn, 200)["data"]
    end

    test "user should send messages", %{user_conn: conn, user_user: user} do
      user2 = insert(:user)

      mutation = """
        mutation {
          sendMessage (receiverId: #{user2.id}){
            sender {
              id
            }
            receiver {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      user_id = to_string(user.id)
      user2_id = to_string(user2.id)

      assert %{
               "sendMessage" => %{
                 "sender" => %{"id" => ^user_id},
                 "receiver" => %{"id" => ^user2_id}
               }
             } = json_response(conn, 200)["data"]
    end

    test "anonymous should not send messages", %{unauthenticated_conn: conn} do
      user = insert(:user)

      mutation = """
        mutation {
          sendMessage (receiverId: #{user.id}){
            sender {
              id
            }
            receiver {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert %{"errors" => [%{"message" => "unauthorized"}]} = json_response(conn, 200)
    end
  end

  describe "listingUserMessages" do
    test "admin should list messages per listing", %{admin_conn: conn, admin_user: admin_user} do
      user = insert(:user)
      listing = insert(:listing)

      %{id: id1} =
        insert(:message, sender_id: admin_user.id, receiver_id: user.id, listing_id: listing.id)

      %{id: id2} =
        insert(:message, sender_id: user.id, receiver_id: admin_user.id, listing_id: listing.id)

      %{id: id3} =
        insert(:message, sender_id: user.id, receiver_id: admin_user.id, listing_id: listing.id)

      insert(:message, sender_id: user.id, receiver_id: admin_user.id)

      query = """
        {
          listingUserMessages (listingId: #{listing.id}) {
            id
            message
          }
        }
      """

      id1 = to_string(id1)
      id2 = to_string(id2)
      id3 = to_string(id3)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listingUserMessages"))

      assert %{
               "listingUserMessages" => [
                 %{"id" => ^id1},
                 %{"id" => ^id2},
                 %{"id" => ^id3}
               ]
             } = json_response(conn, 200)["data"]
    end

    test "user should list messages per listing", %{user_conn: conn, user_user: user} do
      admin_user = insert(:user, role: "admin")
      listing = insert(:listing)

      %{id: id1} =
        insert(:message, sender_id: admin_user.id, receiver_id: user.id, listing_id: listing.id)

      %{id: id2} =
        insert(:message, sender_id: user.id, receiver_id: admin_user.id, listing_id: listing.id)

      %{id: id3} =
        insert(:message, sender_id: user.id, receiver_id: admin_user.id, listing_id: listing.id)

      insert(:message, sender_id: user.id, receiver_id: admin_user.id)

      query = """
        {
          listingUserMessages (listingId: #{listing.id}) {
            id
            message
          }
        }
      """

      id1 = to_string(id1)
      id2 = to_string(id2)
      id3 = to_string(id3)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listingUserMessages"))

      assert %{
               "listingUserMessages" => [
                 %{"id" => ^id1},
                 %{"id" => ^id2},
                 %{"id" => ^id3}
               ]
             } = json_response(conn, 200)["data"]
    end

    test "anonymous should not list messages per listing", %{unauthenticated_conn: conn} do
      query = """
        {
          listingUserMessages {
            id
            message
          }
        }
      """

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listingUserMessages"))

      assert %{"errors" => [%{"message" => "unauthorized"}]} = json_response(conn, 200)
    end
  end
end
