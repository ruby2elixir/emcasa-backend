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
    @tags_query """
    query {
      tags {
        name_slug
        visibility
      }
    }
    """

    test "admin should query tags", %{admin_conn: conn} do
      expected_tags = [
        %{"name_slug" => "academia", "visibility" => "public"},
        %{"name_slug" => "churrasqueira", "visibility" => "public"},
        %{"name_slug" => "espaco-gourmet", "visibility" => "public"},
        %{"name_slug" => "espaco-verde", "visibility" => "public"},
        %{"name_slug" => "parque", "visibility" => "public"},
        %{"name_slug" => "piscina", "visibility" => "public"},
        %{"name_slug" => "playground", "visibility" => "public"},
        %{"name_slug" => "quadra", "visibility" => "public"},
        %{"name_slug" => "salao-de-festas", "visibility" => "public"},
        %{"name_slug" => "salao-de-jogos", "visibility" => "public"},
        %{"name_slug" => "sauna", "visibility" => "public"},
        %{"name_slug" => "armarios-embutidos", "visibility" => "public"},
        %{"name_slug" => "banheiro-empregados", "visibility" => "public"},
        %{"name_slug" => "bom-para-pets", "visibility" => "public"},
        %{"name_slug" => "dependencia-empregados", "visibility" => "public"},
        %{"name_slug" => "espaco-para-churrasco", "visibility" => "public"},
        %{"name_slug" => "fogao-embutido", "visibility" => "public"},
        %{"name_slug" => "lavabo", "visibility" => "public"},
        %{"name_slug" => "reformado", "visibility" => "public"},
        %{"name_slug" => "sacada", "visibility" => "public"},
        %{"name_slug" => "terraco", "visibility" => "public"},
        %{"name_slug" => "vaga-na-escritura", "visibility" => "public"},
        %{"name_slug" => "varanda", "visibility" => "public"},
        %{"name_slug" => "varanda-gourmet", "visibility" => "public"},
        %{"name_slug" => "comunidade", "visibility" => "private"},
        %{"name_slug" => "cristo", "visibility" => "public"},
        %{"name_slug" => "lagoa", "visibility" => "public"},
        %{"name_slug" => "mar", "visibility" => "public"},
        %{"name_slug" => "montanhas", "visibility" => "public"},
        %{"name_slug" => "parcial-comunidade", "visibility" => "private"},
        %{"name_slug" => "parcial-mar", "visibility" => "public"},
        %{"name_slug" => "pedras", "visibility" => "public"},
        %{"name_slug" => "verde", "visibility" => "public"},
        %{"name_slug" => "vizinho", "visibility" => "private"}
      ]

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@tags_query))

      assert json_response(conn, 200)["data"] == %{"tags" => expected_tags}
    end

    test "user should query public tags", %{user_conn: conn} do
      expected_tags = [
        %{"name_slug" => "academia", "visibility" => "public"},
        %{"name_slug" => "churrasqueira", "visibility" => "public"},
        %{"name_slug" => "espaco-gourmet", "visibility" => "public"},
        %{"name_slug" => "espaco-verde", "visibility" => "public"},
        %{"name_slug" => "parque", "visibility" => "public"},
        %{"name_slug" => "piscina", "visibility" => "public"},
        %{"name_slug" => "playground", "visibility" => "public"},
        %{"name_slug" => "quadra", "visibility" => "public"},
        %{"name_slug" => "salao-de-festas", "visibility" => "public"},
        %{"name_slug" => "salao-de-jogos", "visibility" => "public"},
        %{"name_slug" => "sauna", "visibility" => "public"},
        %{"name_slug" => "armarios-embutidos", "visibility" => "public"},
        %{"name_slug" => "banheiro-empregados", "visibility" => "public"},
        %{"name_slug" => "bom-para-pets", "visibility" => "public"},
        %{"name_slug" => "dependencia-empregados", "visibility" => "public"},
        %{"name_slug" => "espaco-para-churrasco", "visibility" => "public"},
        %{"name_slug" => "fogao-embutido", "visibility" => "public"},
        %{"name_slug" => "lavabo", "visibility" => "public"},
        %{"name_slug" => "reformado", "visibility" => "public"},
        %{"name_slug" => "sacada", "visibility" => "public"},
        %{"name_slug" => "terraco", "visibility" => "public"},
        %{"name_slug" => "vaga-na-escritura", "visibility" => "public"},
        %{"name_slug" => "varanda", "visibility" => "public"},
        %{"name_slug" => "varanda-gourmet", "visibility" => "public"},
        %{"name_slug" => "cristo", "visibility" => "public"},
        %{"name_slug" => "lagoa", "visibility" => "public"},
        %{"name_slug" => "mar", "visibility" => "public"},
        %{"name_slug" => "montanhas", "visibility" => "public"},
        %{"name_slug" => "parcial-mar", "visibility" => "public"},
        %{"name_slug" => "pedras", "visibility" => "public"},
        %{"name_slug" => "verde", "visibility" => "public"}
      ]

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@tags_query))

      assert json_response(conn, 200)["data"] == %{"tags" => expected_tags}
    end

    test "anonymous user should query public tags", %{unauthenticated_conn: conn} do
      expected_tags = [
        %{"name_slug" => "academia", "visibility" => "public"},
        %{"name_slug" => "churrasqueira", "visibility" => "public"},
        %{"name_slug" => "espaco-gourmet", "visibility" => "public"},
        %{"name_slug" => "espaco-verde", "visibility" => "public"},
        %{"name_slug" => "parque", "visibility" => "public"},
        %{"name_slug" => "piscina", "visibility" => "public"},
        %{"name_slug" => "playground", "visibility" => "public"},
        %{"name_slug" => "quadra", "visibility" => "public"},
        %{"name_slug" => "salao-de-festas", "visibility" => "public"},
        %{"name_slug" => "salao-de-jogos", "visibility" => "public"},
        %{"name_slug" => "sauna", "visibility" => "public"},
        %{"name_slug" => "armarios-embutidos", "visibility" => "public"},
        %{"name_slug" => "banheiro-empregados", "visibility" => "public"},
        %{"name_slug" => "bom-para-pets", "visibility" => "public"},
        %{"name_slug" => "dependencia-empregados", "visibility" => "public"},
        %{"name_slug" => "espaco-para-churrasco", "visibility" => "public"},
        %{"name_slug" => "fogao-embutido", "visibility" => "public"},
        %{"name_slug" => "lavabo", "visibility" => "public"},
        %{"name_slug" => "reformado", "visibility" => "public"},
        %{"name_slug" => "sacada", "visibility" => "public"},
        %{"name_slug" => "terraco", "visibility" => "public"},
        %{"name_slug" => "vaga-na-escritura", "visibility" => "public"},
        %{"name_slug" => "varanda", "visibility" => "public"},
        %{"name_slug" => "varanda-gourmet", "visibility" => "public"},
        %{"name_slug" => "cristo", "visibility" => "public"},
        %{"name_slug" => "lagoa", "visibility" => "public"},
        %{"name_slug" => "mar", "visibility" => "public"},
        %{"name_slug" => "montanhas", "visibility" => "public"},
        %{"name_slug" => "parcial-mar", "visibility" => "public"},
        %{"name_slug" => "pedras", "visibility" => "public"},
        %{"name_slug" => "verde", "visibility" => "public"}
      ]

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@tags_query))

      assert json_response(conn, 200)["data"] == %{"tags" => expected_tags}
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

      assert nil == json_response(resp_private, 200)["data"]["tag"]
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

      assert nil == json_response(resp_private, 200)["data"]["tag"]
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

      assert nil == json_response(conn, 200)["data"]["tagsSearch"]
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

      assert nil == json_response(conn, 200)["data"]["tagsSearch"]
    end
  end
end
