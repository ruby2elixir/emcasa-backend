defmodule ReWeb.GraphQL.Tags.MutationTest do
  use ReWeb.{
    AbsintheAssertions,
    ConnCase
  }

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

  describe "insert" do
    @insert_mutation """
    mutation TagInsert ($input: TagInput!) {
      tagInsert(input: $input) {
        uuid
        name
        nameSlug
        category
        visibility
      }
    }
    """

    test "admin should insert tag", %{admin_conn: conn} do
      variables = %{
        input: %{
          name: "Tag 1",
          visibility: "public",
          category: "infrastructure"
        }
      }

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@insert_mutation, variables))

      assert insert_tag = json_response(conn, 200)["data"]["tagInsert"]

      assert insert_tag["uuid"]
      assert insert_tag["name"] == variables.input.name
      assert insert_tag["nameSlug"] == "tag-1"
      assert insert_tag["category"] == variables.input.category
      assert insert_tag["visibility"] == variables.input.visibility
    end

    test "user should not insert tag", %{user_conn: conn} do
      variables = %{
        input: %{
          name: "Tag 1",
          visibility: "public",
          category: "infrastructure"
        }
      }

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@insert_mutation, variables))

      assert [error | _] = json_response(conn, 200)["errors"]

      assert error["message"] == "Forbidden"
    end

    test "anonymous user should not insert tag", %{unauthenticated_conn: conn} do
      variables = %{
        input: %{
          name: "Tag 1",
          visibility: "public",
          category: "infrastructure"
        }
      }

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@insert_mutation, variables))

      assert [error | _] = json_response(conn, 200)["errors"]

      assert error["message"] == "Unauthorized"
    end
  end

  describe "update" do
    @update_mutation """
    mutation TagUpdate (
      $uuid: UUID!,
      $input: TagInput!
    ) {
      tagUpdate (uuid: $uuid, input: $input) {
        uuid
        name
        nameSlug
        category
        visibility
      }
    }
    """

    test "admin user should update a tag", %{admin_conn: conn} do
      tag = insert(:tag, name: "Tag 1", name_slug: "tag-1")

      variables = %{
        uuid: tag.uuid,
        input: %{
          name: "Tag 2",
          category: tag.category,
          visibility: tag.visibility
        }
      }

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@update_mutation, variables))

      assert update_tag = json_response(conn, 200)["data"]["tagUpdate"]

      assert update_tag["uuid"] == tag.uuid
      assert update_tag["name"] == variables.input.name
      assert update_tag["nameSlug"] == "tag-2"
      assert update_tag["category"] == tag.category
      assert update_tag["visibility"] == tag.visibility
    end

    test "user should not update tag", %{user_conn: conn} do
      tag = insert(:tag, name: "Tag 1", name_slug: "tag-1")

      variables = %{
        uuid: tag.uuid,
        input: %{
          name: "Tag 2",
          category: tag.category,
          visibility: tag.visibility
        }
      }

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@update_mutation, variables))

      assert [error | _] = json_response(conn, 200)["errors"]

      assert error["message"] == "Forbidden"
    end

    test "anonymous user should not insert tag", %{unauthenticated_conn: conn} do
      tag = insert(:tag, name: "Tag 1", name_slug: "tag-1")

      variables = %{
        uuid: tag.uuid,
        input: %{
          name: "Tag 2",
          category: tag.category,
          visibility: tag.visibility
        }
      }

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@update_mutation, variables))

      assert [error | _] = json_response(conn, 200)["errors"]

      assert error["message"] == "Unauthorized"
    end
  end
end
