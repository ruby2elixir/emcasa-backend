defmodule ReWeb.GraphQL.Developments.MutationTest do
  use ReWeb.{AbsintheAssertions, ConnCase}

  import Re.Factory

  alias ReWeb.{
    AbsintheHelpers
  }

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")
    address = insert(:address)

    development = build(:development)

    {:ok,
     unauthenticated_conn: conn,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user),
     old_development: insert(:development),
     development: development,
     address: address}
  end

  describe "insertDevelopment/2" do
    @insert_mutation """
      mutation InsertDevelopment ($input: DevelopmentInput!) {
        insertDevelopment(input: $input) {
          id
          name
          title
          phase
          builder
          description
          address {
            id
          }
        }
      }
    """

    test "admin should insert development", %{
      admin_conn: conn,
      development: development,
      address: address
    } do
      variables = insert_development_variables(development, address)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@insert_mutation, variables))

      assert %{
               "insertDevelopment" => %{"address" => inserted_address} = insert_development
             } = json_response(conn, 200)["data"]

      assert insert_development["id"]
      assert insert_development["name"] == development.name
      assert insert_development["title"] == development.title
      assert insert_development["phase"] == development.phase
      assert insert_development["builder"] == development.builder
      assert insert_development["description"] == development.description

      assert inserted_address["id"] == Integer.to_string(address.id)
    end

    test "regular user should not insert development", %{
      user_conn: conn,
      development: development,
      address: address
    } do
      variables = insert_development_variables(development, address)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@insert_mutation, variables))

      assert %{"insertDevelopment" => nil} == json_response(conn, 200)["data"]

      assert_forbidden_response(json_response(conn, 200))
    end

    test "unauthenticated user should not insert a development", %{
      unauthenticated_conn: conn,
      development: development,
      address: address
    } do
      variables = insert_development_variables(development, address)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@insert_mutation, variables))

      assert %{"insertDevelopment" => nil} == json_response(conn, 200)["data"]

      assert_unauthorized_response(json_response(conn, 200))
    end
  end

  describe "updateDevelopment/2" do
    @update_mutation """
      mutation UpdateDevelopment ($id: ID!, $input: DevelopmentInput!) {
        updateDevelopment(id: $id, input: $input) {
          id
          name
          title
          phase
          builder
          description
          address {
            id
          }
        }
      }
    """

    test "admin should update development", %{
      admin_conn: conn,
      old_development: old_development,
      development: new_development,
      address: new_address
    } do
      variables = update_development_variables(old_development.id, new_development, new_address)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@update_mutation, variables))

      assert %{
               "updateDevelopment" => %{"address" => updated_address} = updated_development
             } = json_response(conn, 200)["data"]

      assert updated_development["name"] == new_development.name
      assert updated_development["title"] == new_development.title
      assert updated_development["builder"] == new_development.builder
      assert updated_development["phase"] == new_development.phase
      assert updated_development["description"] == new_development.description

      assert updated_address["id"] == Integer.to_string(new_address.id)
    end

    test "regular user should not update a development", %{
      user_conn: conn,
      old_development: old_development,
      development: new_development,
      address: new_address
    } do
      variables = update_development_variables(old_development.id, new_development, new_address)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@update_mutation, variables))

      assert %{"updateDevelopment" => nil} == json_response(conn, 200)["data"]

      assert_forbidden_response(json_response(conn, 200))
    end

    test "unauthenticated user should not update a development", %{
      unauthenticated_conn: conn,
      old_development: old_development,
      development: new_development,
      address: new_address
    } do
      variables = update_development_variables(old_development.id, new_development, new_address)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@update_mutation, variables))

      assert %{"updateDevelopment" => nil} == json_response(conn, 200)["data"]

      assert_unauthorized_response(json_response(conn, 200))
    end
  end

  def insert_development_variables(development, address) do
    %{
      "input" => %{
        "name" => development.name,
        "title" => development.title,
        "phase" => development.phase,
        "builder" => development.builder,
        "description" => development.description,
        "address_id" => address.id
      }
    }
  end

  def update_development_variables(id, development, address) do
    %{
      "id" => id,
      "input" => %{
        "name" => development.name,
        "title" => development.title,
        "phase" => development.phase,
        "builder" => development.builder,
        "description" => development.description,
        "address_id" => address.id
      }
    }
  end
end
