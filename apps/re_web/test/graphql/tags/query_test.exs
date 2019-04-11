defmodule ReWeb.GraphQL.Tags.QueryTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {
      :ok,
      unauthenticated_conn: conn,
      admin_conn: login_as(conn, admin_user),
      user_conn: login_as(conn, user_user)
    }
  end

  describe "tags" do
    test "admin should fetch all tags", %{admin_conn: conn} do
      expected_tags = [
        %{"nameSlug" => "academia", "visibility" => "public"},
        %{"nameSlug" => "churrasqueira", "visibility" => "public"},
        %{"nameSlug" => "espaco-gourmet", "visibility" => "public"},
        %{"nameSlug" => "espaco-verde", "visibility" => "public"},
        %{"nameSlug" => "parque", "visibility" => "public"},
        %{"nameSlug" => "piscina", "visibility" => "public"},
        %{"nameSlug" => "playground", "visibility" => "public"},
        %{"nameSlug" => "quadra", "visibility" => "public"},
        %{"nameSlug" => "salao-de-festas", "visibility" => "public"},
        %{"nameSlug" => "salao-de-jogos", "visibility" => "public"},
        %{"nameSlug" => "sauna", "visibility" => "public"},
        %{"nameSlug" => "armarios-embutidos", "visibility" => "public"},
        %{"nameSlug" => "banheiro-empregados", "visibility" => "public"},
        %{"nameSlug" => "bom-para-pets", "visibility" => "public"},
        %{"nameSlug" => "dependencia-empregados", "visibility" => "public"},
        %{"nameSlug" => "espaco-para-churrasco", "visibility" => "public"},
        %{"nameSlug" => "fogao-embutido", "visibility" => "public"},
        %{"nameSlug" => "lavabo", "visibility" => "public"},
        %{"nameSlug" => "reformado", "visibility" => "public"},
        %{"nameSlug" => "sacada", "visibility" => "public"},
        %{"nameSlug" => "terraco", "visibility" => "public"},
        %{"nameSlug" => "vaga-na-escritura", "visibility" => "public"},
        %{"nameSlug" => "varanda", "visibility" => "public"},
        %{"nameSlug" => "varanda-gourmet", "visibility" => "public"},
        %{"nameSlug" => "comunidade", "visibility" => "private"},
        %{"nameSlug" => "cristo", "visibility" => "public"},
        %{"nameSlug" => "lagoa", "visibility" => "public"},
        %{"nameSlug" => "mar", "visibility" => "public"},
        %{"nameSlug" => "montanhas", "visibility" => "public"},
        %{"nameSlug" => "parcial-comunidade", "visibility" => "private"},
        %{"nameSlug" => "parcial-mar", "visibility" => "public"},
        %{"nameSlug" => "pedras", "visibility" => "public"},
        %{"nameSlug" => "verde", "visibility" => "public"},
        %{"nameSlug" => "vizinho", "visibility" => "private"}
      ]

      query = """
        query {
          tags {
            nameSlug
            visibility
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert json_response(conn, 200)["data"] == %{"tags" => expected_tags}
    end

    test "admin should filter private tags", %{admin_conn: conn} do
      expected_tags = [
        %{"nameSlug" => "comunidade", "visibility" => "private"},
        %{"nameSlug" => "parcial-comunidade", "visibility" => "private"},
        %{"nameSlug" => "vizinho", "visibility" => "private"}
      ]

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

      assert json_response(conn, 200)["data"] == %{"tags" => expected_tags}
    end

    test "user should query public tags", %{user_conn: conn} do
      expected_tags = [
        %{"nameSlug" => "academia", "visibility" => "public"},
        %{"nameSlug" => "churrasqueira", "visibility" => "public"},
        %{"nameSlug" => "espaco-gourmet", "visibility" => "public"},
        %{"nameSlug" => "espaco-verde", "visibility" => "public"},
        %{"nameSlug" => "parque", "visibility" => "public"},
        %{"nameSlug" => "piscina", "visibility" => "public"},
        %{"nameSlug" => "playground", "visibility" => "public"},
        %{"nameSlug" => "quadra", "visibility" => "public"},
        %{"nameSlug" => "salao-de-festas", "visibility" => "public"},
        %{"nameSlug" => "salao-de-jogos", "visibility" => "public"},
        %{"nameSlug" => "sauna", "visibility" => "public"},
        %{"nameSlug" => "armarios-embutidos", "visibility" => "public"},
        %{"nameSlug" => "banheiro-empregados", "visibility" => "public"},
        %{"nameSlug" => "bom-para-pets", "visibility" => "public"},
        %{"nameSlug" => "dependencia-empregados", "visibility" => "public"},
        %{"nameSlug" => "espaco-para-churrasco", "visibility" => "public"},
        %{"nameSlug" => "fogao-embutido", "visibility" => "public"},
        %{"nameSlug" => "lavabo", "visibility" => "public"},
        %{"nameSlug" => "reformado", "visibility" => "public"},
        %{"nameSlug" => "sacada", "visibility" => "public"},
        %{"nameSlug" => "terraco", "visibility" => "public"},
        %{"nameSlug" => "vaga-na-escritura", "visibility" => "public"},
        %{"nameSlug" => "varanda", "visibility" => "public"},
        %{"nameSlug" => "varanda-gourmet", "visibility" => "public"},
        %{"nameSlug" => "cristo", "visibility" => "public"},
        %{"nameSlug" => "lagoa", "visibility" => "public"},
        %{"nameSlug" => "mar", "visibility" => "public"},
        %{"nameSlug" => "montanhas", "visibility" => "public"},
        %{"nameSlug" => "parcial-mar", "visibility" => "public"},
        %{"nameSlug" => "pedras", "visibility" => "public"},
        %{"nameSlug" => "verde", "visibility" => "public"}
      ]

      query = """
        query {
          tags {
            nameSlug
            visibility
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert json_response(conn, 200)["data"] == %{"tags" => expected_tags}
    end

    test "anonymous user should query public tags", %{unauthenticated_conn: conn} do
      expected_tags = [
        %{"nameSlug" => "academia", "visibility" => "public"},
        %{"nameSlug" => "churrasqueira", "visibility" => "public"},
        %{"nameSlug" => "espaco-gourmet", "visibility" => "public"},
        %{"nameSlug" => "espaco-verde", "visibility" => "public"},
        %{"nameSlug" => "parque", "visibility" => "public"},
        %{"nameSlug" => "piscina", "visibility" => "public"},
        %{"nameSlug" => "playground", "visibility" => "public"},
        %{"nameSlug" => "quadra", "visibility" => "public"},
        %{"nameSlug" => "salao-de-festas", "visibility" => "public"},
        %{"nameSlug" => "salao-de-jogos", "visibility" => "public"},
        %{"nameSlug" => "sauna", "visibility" => "public"},
        %{"nameSlug" => "armarios-embutidos", "visibility" => "public"},
        %{"nameSlug" => "banheiro-empregados", "visibility" => "public"},
        %{"nameSlug" => "bom-para-pets", "visibility" => "public"},
        %{"nameSlug" => "dependencia-empregados", "visibility" => "public"},
        %{"nameSlug" => "espaco-para-churrasco", "visibility" => "public"},
        %{"nameSlug" => "fogao-embutido", "visibility" => "public"},
        %{"nameSlug" => "lavabo", "visibility" => "public"},
        %{"nameSlug" => "reformado", "visibility" => "public"},
        %{"nameSlug" => "sacada", "visibility" => "public"},
        %{"nameSlug" => "terraco", "visibility" => "public"},
        %{"nameSlug" => "vaga-na-escritura", "visibility" => "public"},
        %{"nameSlug" => "varanda", "visibility" => "public"},
        %{"nameSlug" => "varanda-gourmet", "visibility" => "public"},
        %{"nameSlug" => "cristo", "visibility" => "public"},
        %{"nameSlug" => "lagoa", "visibility" => "public"},
        %{"nameSlug" => "mar", "visibility" => "public"},
        %{"nameSlug" => "montanhas", "visibility" => "public"},
        %{"nameSlug" => "parcial-mar", "visibility" => "public"},
        %{"nameSlug" => "pedras", "visibility" => "public"},
        %{"nameSlug" => "verde", "visibility" => "public"}
      ]

      query = """
        query {
          tags {
            nameSlug
            visibility
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert json_response(conn, 200)["data"] == %{"tags" => expected_tags}
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

      variables = %{filters: %{nameSlugs: ["salao-de-festas", "academia"]}}

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert data = json_response(conn, 200)["data"]["tags"]
      assert 2 == Enum.count(data)
      assert Enum.member?(data, %{"nameSlug" => "academia"})
      assert Enum.member?(data, %{"nameSlug" => "salao-de-festas"})
    end
  end

  describe "tag" do
    test "admin should fetch public and private tag", %{admin_conn: conn} do
      tag_public = insert(:tag, name: "Public 1", name_slug: "public-1", visibility: "public")
      variable_public = %{"uuid" => tag_public.uuid}

      tag_private = insert(:tag, name: "Private 1", name_slug: "private-1", visibility: "private")
      variable_private = %{"uuid" => tag_private.uuid}

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
        post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variable_public))

      assert %{"name" => tag_public.name, "visibility" => "public"} ==
               json_response(resp_public, 200)["data"]["tag"]

      resp_private =
        post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variable_private))

      assert %{"name" => tag_private.name, "visibility" => "private"} ==
               json_response(resp_private, 200)["data"]["tag"]
    end

    test "user should fetch public tag", %{user_conn: conn} do
      tag_public = insert(:tag, name: "Public 1", name_slug: "public-1", visibility: "public")
      variable_public = %{"uuid" => tag_public.uuid}

      tag_private = insert(:tag, name: "Private 1", name_slug: "private-1", visibility: "private")
      variable_private = %{"uuid" => tag_private.uuid}

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
        post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variable_public))

      assert %{"name" => tag_public.name, "visibility" => "public"} ==
               json_response(resp_public, 200)["data"]["tag"]

      resp_private =
        post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variable_private))

      refute json_response(resp_private, 200)["data"]["tag"]
    end

    test "anonymous user should fetch public tag", %{unauthenticated_conn: conn} do
      tag_public = insert(:tag, name: "Public 1", name_slug: "public-1", visibility: "public")
      variable_public = %{"uuid" => tag_public.uuid}

      tag_private = insert(:tag, name: "Private 1", name_slug: "private-1", visibility: "private")
      variable_private = %{"uuid" => tag_private.uuid}

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
        post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variable_public))

      assert %{"name" => tag_public.name, "visibility" => "public"} ==
               json_response(resp_public, 200)["data"]["tag"]

      resp_private =
        post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variable_private))

      refute json_response(resp_private, 200)["data"]["tag"]
    end
  end

  describe "search" do
    test "admin user should search tags", %{admin_conn: conn} do
      insert(:tag, name: "Party room", name_slug: "party-room")
      insert(:tag, name: "Kids room", name_slug: "kids-room")
      insert(:tag, name: "Pool", name_slug: "pool")

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
      insert(:tag, name: "Party room", name_slug: "party-room")
      insert(:tag, name: "Kids room", name_slug: "kids-room")
      insert(:tag, name: "Pool", name_slug: "pool")

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
      insert(:tag, name: "Party room", name_slug: "party-room")
      insert(:tag, name: "Kids room", name_slug: "kids-room")
      insert(:tag, name: "Pool", name_slug: "pool")

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
