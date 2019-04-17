defmodule ReWeb.GraphQL.Tags.QueryTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    public_tags = [
      insert(:tag,
        name: "Party room",
        name_slug: "party-room",
        category: "infrastructure"
      ),
      insert(:tag,
        name: "Gym",
        name_slug: "gym",
        category: "infrastructure"
      )
    ]

    private_tags = [
      insert(:tag,
        name: "Pool",
        name_slug: "pool",
        category: "infrastructure",
        visibility: "private"
      ),
      insert(:tag,
        name: "Playground",
        name_slug: "playground",
        category: "infrastructure",
        visibility: "private"
      )
    ]

    {
      :ok,
      unauthenticated_conn: conn,
      admin_conn: login_as(conn, admin_user),
      user_conn: login_as(conn, user_user),
      public_tags: public_tags,
      private_tags: private_tags
    }
  end

  describe "tags" do
    test "admin should fetch all tags", %{
      admin_conn: conn,
      public_tags: [tag1, tag2],
      private_tags: [tag3, tag4]
    } do
      query = """
        query {
          tags {
            nameSlug
            visibility
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert tags_response = json_response(conn, 200)["data"]["tags"]

      [tag1_response, tag2_response, tag3_response, tag4_response] = Enum.sort(tags_response)

      assert tag2_response["nameSlug"] == tag1.name_slug
      assert tag2_response["visibility"] == "public"
      assert tag1_response["nameSlug"] == tag2.name_slug
      assert tag1_response["visibility"] == "public"
      assert tag4_response["nameSlug"] == tag3.name_slug
      assert tag4_response["visibility"] == "private"
      assert tag3_response["nameSlug"] == tag4.name_slug
      assert tag3_response["visibility"] == "private"
    end

    test "admin should filter private tags", %{admin_conn: conn, private_tags: [tag1, tag2]} do
      query = """
        query Tags ($filters: TagFilterInput!) {
          tags (filters: $filters) {
            nameSlug
            visibility
          }
        }
      """

      variables = %{filters: %{visibility: "private"}}

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert tags_response = json_response(conn, 200)["data"]["tags"]
      [tag1_response, tag2_response] = Enum.sort(tags_response)

      assert tag2_response["nameSlug"] == tag1.name_slug
      assert tag2_response["visibility"] == "private"
      assert tag1_response["nameSlug"] == tag2.name_slug
      assert tag1_response["visibility"] == "private"
    end

    test "user should query public tags", %{user_conn: conn, public_tags: [tag1, tag2]} do
      query = """
        query {
          tags {
            nameSlug
            visibility
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert tags_response = json_response(conn, 200)["data"]["tags"]
      [tag1_response, tag2_response] = Enum.sort(tags_response)

      assert tag2_response["nameSlug"] == tag1.name_slug
      assert tag2_response["visibility"] == "public"
      assert tag1_response["nameSlug"] == tag2.name_slug
      assert tag1_response["visibility"] == "public"
    end

    test "anonymous user should query public tags", %{
      unauthenticated_conn: conn,
      public_tags: [tag1, tag2]
    } do
      query = """
        query {
          tags {
            nameSlug
            visibility
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert tags_response = json_response(conn, 200)["data"]["tags"]
      [tag1_response, tag2_response] = Enum.sort(tags_response)

      assert tag2_response["nameSlug"] == tag1.name_slug
      assert tag2_response["visibility"] == "public"
      assert tag1_response["nameSlug"] == tag2.name_slug
      assert tag1_response["visibility"] == "public"
    end

    test "filter multiple tags by name slug", %{unauthenticated_conn: conn} do
      query = """
        query Tags (
          $filters: TagFilterInput!
        ) {
          tags(filters: $filters) {
            nameSlug
          }
        }
      """

      variables = %{filters: %{nameSlugs: ["party-room"]}}

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert [tag] = json_response(conn, 200)["data"]["tags"]
      assert tag["nameSlug"] == "party-room"
    end
  end

  describe "tag" do
    test "admin should fetch public and private tag", %{
      admin_conn: conn,
      public_tags: [tag1, _],
      private_tags: [tag2, _]
    } do
      query = """
      query Tag (
        $uuid: UUID!,
      ) {
        tag(uuid: $uuid) {
          name
          visibility
        }
      }
      """

      resp_public =
        post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, %{"uuid" => tag1.uuid}))

      assert %{"name" => tag1.name, "visibility" => "public"} ==
               json_response(resp_public, 200)["data"]["tag"]

      resp_private =
        post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, %{"uuid" => tag2.uuid}))

      assert %{"name" => tag2.name, "visibility" => "private"} ==
               json_response(resp_private, 200)["data"]["tag"]
    end

    test "user should fetch public tag", %{
      user_conn: conn,
      public_tags: [tag1, _],
      private_tags: [tag2, _]
    } do
      query = """
      query Tag (
        $uuid: UUID!,
      ) {
        tag(uuid: $uuid) {
          name
          visibility
        }
      }
      """

      resp_public =
        post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, %{"uuid" => tag1.uuid}))

      assert %{"name" => tag1.name, "visibility" => "public"} ==
               json_response(resp_public, 200)["data"]["tag"]

      resp_private =
        post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, %{"uuid" => tag2.uuid}))

      refute json_response(resp_private, 200)["data"]["tag"]
    end

    test "anonymous user should fetch public tag", %{
      unauthenticated_conn: conn,
      public_tags: [tag1, _],
      private_tags: [tag2, _]
    } do
      query = """
      query Tag (
        $uuid: UUID!,
      ) {
        tag(uuid: $uuid) {
          name
          visibility
        }
      }
      """

      resp_public =
        post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, %{"uuid" => tag1.uuid}))

      assert %{"name" => tag1.name, "visibility" => "public"} ==
               json_response(resp_public, 200)["data"]["tag"]

      resp_private =
        post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, %{"uuid" => tag2.uuid}))

      refute json_response(resp_private, 200)["data"]["tag"]
    end
  end

  describe "search" do
    test "admin user should search tags", %{admin_conn: conn} do
      insert(:tag, name: "Kids room", name_slug: "kids-room")

      variables = %{"name" => "RooM"}

      query = """
      query TagsSearch (
        $name: String!,
      ) {
        tagsSearch(name: $name) {
          name_slug
        }
      }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert [%{"name_slug" => "party-room"}, %{"name_slug" => "kids-room"}] ==
               json_response(conn, 200)["data"]["tagsSearch"]
    end

    test "user should not search tags", %{user_conn: conn} do
      insert(:tag, name: "Kids room", name_slug: "kids-room")

      variables = %{"name" => "RooM"}

      query = """
      query TagsSearch (
        $name: String!,
      ) {
        tagsSearch(name: $name) {
          name_slug
        }
      }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      refute json_response(conn, 200)["data"]["tagsSearch"]
    end

    test "anonymous user should not search tags", %{unauthenticated_conn: conn} do
      insert(:tag, name: "Kids room", name_slug: "kids-room")

      variables = %{"name" => "RooM"}

      query = """
      query TagsSearch (
        $name: String!,
      ) {
        tagsSearch(name: $name) {
          name_slug
        }
      }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      refute json_response(conn, 200)["data"]["tagsSearch"]
    end
  end
end
