defmodule ReWeb.GraphQL.Images.MutationTest do
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

  describe "insert" do
    test "admin should insert image", %{admin_conn: conn} do
      %{id: listing_id} = insert(:listing)

      variables = %{
        "input" => %{
          "listingId" => listing_id,
          "filename" => "test.jpg"
        }
      }

      mutation = """
        mutation InsertImage ($input: ImageInsertInput!) {
          insertImage(input: $input) {
            description
            filename
            isActive
            position
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "description" => nil,
               "filename" => "test.jpg",
               "isActive" => true,
               "position" => 1
             } == json_response(conn, 200)["data"]["insertImage"]
    end

    test "owner should insert image", %{user_conn: conn, user_user: user} do
      %{id: listing_id} = insert(:listing, user: user)

      variables = %{
        "input" => %{
          "listingId" => listing_id,
          "filename" => "test.jpg"
        }
      }

      mutation = """
        mutation InsertImage ($input: ImageInsertInput!) {
          insertImage(input: $input) {
            description
            filename
            isActive
            position
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "description" => nil,
               "filename" => "test.jpg",
               "isActive" => true,
               "position" => 1
             } == json_response(conn, 200)["data"]["insertImage"]
    end

    test "user should not insert image if not owner", %{user_conn: conn, admin_user: user} do
      %{id: listing_id} = insert(:listing, user: user)

      variables = %{
        "input" => %{
          "listingId" => listing_id,
          "filename" => "test.jpg"
        }
      }

      mutation = """
        mutation InsertImage ($input: ImageInsertInput!) {
          insertImage(input: $input) {
            description
            filename
            isActive
            position
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not insert image", %{unauthenticated_conn: conn} do
      %{id: listing_id} = insert(:listing)

      variables = %{
        "input" => %{
          "listingId" => listing_id,
          "filename" => "test.jpg"
        }
      }

      mutation = """
        mutation InsertImage ($input: ImageInsertInput!) {
          insertImage(input: $input) {
            description
            filename
            isActive
            position
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end
  end

  describe "update" do
    test "admin should update image", %{admin_conn: conn} do
      %{id: listing_id} = insert(:listing)

      [%{id: id1}, %{id: id2}, %{id: id3}] =
        insert_list(
          3,
          :image,
          listing_id: listing_id,
          position: 5,
          description: "wah",
          filename: "test.jpg"
        )

      variables = %{
        "input" => [
          %{"id" => id1, "position" => 1, "description" => "waow1"},
          %{"id" => id2, "position" => 2, "description" => "waow2"},
          %{"id" => id3, "position" => 3, "description" => "waow3"}
        ]
      }

      mutation = """
        mutation UpdateImages ($input: ImageUpdateInput!) {
          updateImages(input: $input) {
            id
            description
            filename
            isActive
            position
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [
               %{
                 "id" => to_string(id1),
                 "description" => "waow1",
                 "filename" => "test.jpg",
                 "isActive" => true,
                 "position" => 1
               },
               %{
                 "id" => to_string(id2),
                 "description" => "waow2",
                 "filename" => "test.jpg",
                 "isActive" => true,
                 "position" => 2
               },
               %{
                 "id" => to_string(id3),
                 "description" => "waow3",
                 "filename" => "test.jpg",
                 "isActive" => true,
                 "position" => 3
               }
             ] == json_response(conn, 200)["data"]["updateImages"]

      image1 = Repo.get(Re.Image, id1)
      assert 1 == image1.position
      assert "waow1" == image1.description
      assert "test.jpg" == image1.filename
      assert image1.is_active

      image2 = Repo.get(Re.Image, id2)
      assert 2 == image2.position
      assert "waow2" == image2.description
      assert "test.jpg" == image2.filename
      assert image2.is_active

      image3 = Repo.get(Re.Image, id3)
      assert 3 == image3.position
      assert "waow3" == image3.description
      assert "test.jpg" == image3.filename
      assert image3.is_active
    end

    test "owner should update image", %{user_conn: conn, user_user: user} do
      %{id: listing_id} = insert(:listing, user: user)

      [%{id: id1}, %{id: id2}, %{id: id3}] =
        insert_list(
          3,
          :image,
          listing_id: listing_id,
          position: 5,
          description: "wah",
          filename: "test.jpg"
        )

      variables = %{
        "input" => [
          %{"id" => id1, "position" => 1, "description" => "waow1"},
          %{"id" => id2, "position" => 2, "description" => "waow2"},
          %{"id" => id3, "position" => 3, "description" => "waow3"}
        ]
      }

      mutation = """
        mutation UpdateImages ($input: ImageUpdateInput!) {
          updateImages(input: $input) {
            id
            description
            filename
            isActive
            position
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [
               %{
                 "id" => to_string(id1),
                 "description" => "waow1",
                 "filename" => "test.jpg",
                 "isActive" => true,
                 "position" => 1
               },
               %{
                 "id" => to_string(id2),
                 "description" => "waow2",
                 "filename" => "test.jpg",
                 "isActive" => true,
                 "position" => 2
               },
               %{
                 "id" => to_string(id3),
                 "description" => "waow3",
                 "filename" => "test.jpg",
                 "isActive" => true,
                 "position" => 3
               }
             ] == json_response(conn, 200)["data"]["updateImages"]

      image1 = Repo.get(Re.Image, id1)
      assert 1 == image1.position
      assert "waow1" == image1.description
      assert "test.jpg" == image1.filename
      assert image1.is_active

      image2 = Repo.get(Re.Image, id2)
      assert 2 == image2.position
      assert "waow2" == image2.description
      assert "test.jpg" == image2.filename
      assert image2.is_active

      image3 = Repo.get(Re.Image, id3)
      assert 3 == image3.position
      assert "waow3" == image3.description
      assert "test.jpg" == image3.filename
      assert image3.is_active
    end

    test "user should not update image if not owner", %{user_conn: conn, admin_user: user} do
      %{id: listing_id} = insert(:listing, user: user)

      [%{id: id1}, %{id: id2}, %{id: id3}] =
        insert_list(
          3,
          :image,
          listing_id: listing_id,
          position: 5,
          description: "wah",
          filename: "test.jpg"
        )

      variables = %{
        "input" => [
          %{"id" => id1, "position" => 1, "description" => "waow1"},
          %{"id" => id2, "position" => 2, "description" => "waow2"},
          %{"id" => id3, "position" => 3, "description" => "waow3"}
        ]
      }

      mutation = """
        mutation UpdateImages ($input: ImageUpdateInput!) {
          updateImages(input: $input) {
            id
            description
            filename
            isActive
            position
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not insert image", %{unauthenticated_conn: conn, admin_user: user} do
      %{id: listing_id} = insert(:listing, user: user)

      [%{id: id1}, %{id: id2}, %{id: id3}] =
        insert_list(
          3,
          :image,
          listing_id: listing_id,
          position: 5,
          description: "wah",
          filename: "test.jpg"
        )

      variables = %{
        "input" => [
          %{"id" => id1, "position" => 1, "description" => "waow1"},
          %{"id" => id2, "position" => 2, "description" => "waow2"},
          %{"id" => id3, "position" => 3, "description" => "waow3"}
        ]
      }

      mutation = """
        mutation UpdateImages ($input: ImageUpdateInput!) {
          updateImages(input: $input) {
            id
            description
            filename
            isActive
            position
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end
  end
end
