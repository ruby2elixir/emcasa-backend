defmodule ReWeb.GraphQL.DashboardTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  describe "dashboard" do
    test "admin should query dashboard", %{admin_conn: conn} do
      insert(:listing, is_active: false)
      insert(:listing,
        listings_visualisations: [build(:listing_visualisation)],
        tour_visualisations: [build(:tour_visualisation)],
        listings_favorites: [build(:listings_favorites)],
        maintenance_fee: 123.321,
        property_tax: 321.123,
        matterport_code: "asdsa",
        area: 50
      )
      insert(:listing,
        maintenance_fee: nil,
        property_tax: nil,
        matterport_code: nil,
        area: nil
      )

      query = """
        {
          dashboard {
            activeListingCount
            favoriteCount
            visualizationCount
            tourVisualizationCount
            maintenanceFeeCount
            propertyTaxCount
            tourCount
            areaCount
          }
        }
      """

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "dashboard"))

      assert %{
               "dashboard" => %{
                 "activeListingCount" => 2,
                 "favoriteCount" => 1,
                 "visualizationCount" => 1,
                 "tourVisualizationCount" => 1,
                 "maintenanceFeeCount" => 1,
                 "propertyTaxCount" => 1,
                 "tourCount" => 1,
                 "areaCount" => 1
               }
             } = json_response(conn, 200)["data"]
    end

    test "user should not query dashboard", %{user_conn: conn} do
      query = """
        {
          dashboard {
            activeListingCount
            favoriteCount
            visualizationCount
            tourVisualizationCount
            maintenanceFeeCount
            propertyTaxCount
            tourCount
            areaCount
          }
        }
      """

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "dashbard"))

      assert [%{"message" => "forbidden"}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not query dashboard", %{unauthenticated_conn: conn} do
      query = """
        {
          dashboard {
            activeListingCount
            favoriteCount
            visualizationCount
            tourVisualizationCount
            maintenanceFeeCount
            propertyTaxCount
            tourCount
            areaCount
          }
        }
      """

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "dashbard"))

      assert [%{"message" => "unautenticated"}] = json_response(conn, 200)["errors"]
    end
  end
end
