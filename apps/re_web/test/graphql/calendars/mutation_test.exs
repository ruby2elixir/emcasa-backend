defmodule ReWeb.GraphQL.Calendars.MutationTest do
  use ReWeb.ConnCase

  alias ReWeb.AbsintheHelpers

  import Re.Factory

  alias Re.{
    Calendars.TourAppointment,
    Repo
  }

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_conn: login_as(conn, admin_user),
     admin_user: admin_user,
     user_conn: login_as(conn, user_user),
     user_user: user_user}
  end

  test "admin should schedule tour appointment", %{admin_conn: conn, admin_user: user} do
    listing = insert(:listing)

    args = %{
      "input" => %{
        "options" => [
          %{"datetime" => "2018-01-01T10:00:00.000000"}
        ],
        "wantsPictures" => true,
        "wantsTour" => true,
        "listingId" => listing.id
      }
    }

    mutation = """
      mutation TourSchedule($input: TourScheduleInput!) {
        tourSchedule(input: $input) {
          id
          wantsPictures
          wantsTour
          options {
            datetime
          }
          user {
            id
          }
          listing {
            id
          }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, args))

    response = json_response(conn, 200)

    assert %{"id" => to_string(user.id)} == response["data"]["tourSchedule"]["user"]
    assert %{"id" => to_string(listing.id)} == response["data"]["tourSchedule"]["listing"]

    assert [%{"datetime" => "2018-01-01T10:00:00"}] == response["data"]["tourSchedule"]["options"]

    assert response["data"]["tourSchedule"]["wantsTour"]
    assert response["data"]["tourSchedule"]["wantsPictures"]

    id = response["data"]["tourSchedule"]["id"]
    assert Repo.get(TourAppointment, id)
  end

  test "user should schedule tour appointment", %{user_conn: conn, user_user: user} do
    listing = insert(:listing)

    args = %{
      "input" => %{
        "options" => [
          %{"datetime" => "2018-01-01T10:00:00.000000"}
        ],
        "wantsPictures" => true,
        "wantsTour" => true,
        "listingId" => listing.id
      }
    }

    mutation = """
      mutation TourSchedule($input: TourScheduleInput!) {
        tourSchedule(input: $input) {
          id
          wantsPictures
          wantsTour
          options {
            datetime
          }
          user {
            id
          }
          listing {
            id
          }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, args))

    response = json_response(conn, 200)

    assert %{"id" => to_string(user.id)} == response["data"]["tourSchedule"]["user"]
    assert %{"id" => to_string(listing.id)} == response["data"]["tourSchedule"]["listing"]

    assert [%{"datetime" => "2018-01-01T10:00:00"}] == response["data"]["tourSchedule"]["options"]

    assert response["data"]["tourSchedule"]["wantsTour"]
    assert response["data"]["tourSchedule"]["wantsPictures"]

    id = response["data"]["tourSchedule"]["id"]
    assert Repo.get(TourAppointment, id)
  end

  test "anonymous should not schedule tour appointment", %{unauthenticated_conn: conn} do
    listing = insert(:listing)

    args = %{
      "input" => %{
        "options" => [
          %{"datetime" => "2018-01-01T10:00:00.000000"}
        ],
        "wantsPictures" => true,
        "wantsTour" => true,
        "listingId" => listing.id
      }
    }

    mutation = """
      mutation TourSchedule($input: TourScheduleInput!) {
        tourSchedule(input: $input) {
          id
          wantsPictures
          wantsTour
          options {
            datetime
          }
          user {
            id
          }
          listing {
            id
          }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, args))

    assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
  end
end
