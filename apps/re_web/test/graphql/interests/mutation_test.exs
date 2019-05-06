defmodule ReWeb.GraphQL.Interests.MutationTest do
  use ReWeb.ConnCase

  alias ReWeb.AbsintheHelpers

  import Re.Factory

  alias Re.{
    Interest,
    Repo
  }

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok, unauthenticated_conn: conn, user_user: user_user, user_conn: login_as(conn, user_user)}
  end

  test "anonymous should request contact", %{unauthenticated_conn: conn} do
    %{id: interest_type_id, name: interest_type_name} = insert(:interest_type)
    %{id: listing_id} = insert(:listing)

    variables = %{
      "input" => %{
        "name" => "Mah Name",
        "email" => "testemail@emcasa.com",
        "phone" => "123321123",
        "message" => "this website is cool",
        "interestTypeId" => interest_type_id,
        "listingId" => listing_id
      }
    }

    mutation = """
      mutation InterestCreate($input: InterestInput!) {
        interestCreate(input: $input) {
          name
          email
          phone
          message
          listing {
            id
          }
          interestType {
            id
            name
          }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

    assert %{
             "name" => "Mah Name",
             "email" => "testemail@emcasa.com",
             "phone" => "123321123",
             "message" => "this website is cool",
             "interestType" => %{
               "id" => to_string(interest_type_id),
               "name" => interest_type_name
             },
             "listing" => %{
               "id" => to_string(listing_id)
             }
           } == json_response(conn, 200)["data"]["interestCreate"]

    assert interest = Repo.get_by(Interest, name: "Mah Name")
    assert interest.uuid
  end

  test "user should request contact", %{user_conn: conn} do
    %{id: interest_type_id, name: interest_type_name} = insert(:interest_type)
    %{id: listing_id} = insert(:listing)

    variables = %{
      "input" => %{
        "name" => "Mah Name",
        "email" => "testemail@emcasa.com",
        "phone" => "123321123",
        "message" => "this website is cool",
        "interestTypeId" => interest_type_id,
        "listingId" => listing_id
      }
    }

    mutation = """
      mutation InterestCreate($input: InterestInput!) {
        interestCreate(input: $input) {
          name
          email
          phone
          message
          listing {
            id
          }
          interestType {
            id
            name
          }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

    assert %{
             "name" => "Mah Name",
             "email" => "testemail@emcasa.com",
             "phone" => "123321123",
             "message" => "this website is cool",
             "interestType" => %{
               "id" => to_string(interest_type_id),
               "name" => interest_type_name
             },
             "listing" => %{
               "id" => to_string(listing_id)
             }
           } == json_response(conn, 200)["data"]["interestCreate"]

    assert interest = Repo.get_by(Interest, name: "Mah Name")
    assert interest.uuid
  end
end
