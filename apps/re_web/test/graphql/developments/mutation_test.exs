defmodule ReWeb.GraphQL.Developments.MutationTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.{
    AbsintheHelpers,
    Listing.MutationHelpers
  }

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    development = build(:development)
    address = build(:address)

    {:ok,
     unauthenticated_conn: conn,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user),
     development: development,
     address: address}
  end

  describe "insertDevelopment/2" do
    test "admin should insert development", %{
      admin_conn: conn,
      development: development,
      address: address
    } do
      variables = MutationHelpers.insert_development_variables(development, address)

      mutation = MutationHelpers.insert_development_mutation()

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "insertDevelopment" => %{"address" => inserted_address} = insert_development
             } = json_response(conn, 200)["data"]

      assert insert_development["id"]
      assert insert_development["name"] == development.name
      assert insert_development["title"] == development.title
      assert insert_development["phase"] == development.phase
      assert insert_development["builder"] == development.builder
      assert insert_development["description"] == development.description

      assert inserted_address["city"] == address.city
      assert inserted_address["state"] == address.state
      assert inserted_address["lat"] == address.lat
      assert inserted_address["lng"] == address.lng
      assert inserted_address["neighborhood"] == address.neighborhood
      assert inserted_address["street"] == address.street
      assert inserted_address["streetNumber"] == address.street_number
      assert inserted_address["postalCode"] == address.postal_code
    end

    test "regular user should not insert development", %{
      user_conn: conn,
      development: development,
      address: address
    } do
      variables = MutationHelpers.insert_development_variables(development, address)

      mutation = MutationHelpers.insert_development_mutation()

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{"insertDevelopment" => nil} = json_response(conn, 200)["data"]

      error =
        json_response(conn, 200)["errors"]
        |> List.first()

      assert 403 = error["code"]
      assert "Forbidden" = error["message"]
    end

    test "unauthenticated user should not insert a development", %{
      user_conn: conn,
      development: development,
      address: address
    } do
      variables = MutationHelpers.insert_development_variables(development, address)

      mutation = MutationHelpers.insert_development_mutation()

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{"insertDevelopment" => nil} = json_response(conn, 200)["data"]

      error =
        json_response(conn, 200)["errors"]
        |> List.first()

      assert 403 = error["code"]
      assert "Forbidden" = error["message"]
    end
  end
end
