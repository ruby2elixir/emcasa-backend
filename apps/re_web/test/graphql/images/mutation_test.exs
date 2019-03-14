defmodule ReWeb.GraphQL.Images.MutationTest do
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
            image {
              description
              filename
              isActive
              position
              category
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "image" => %{
                 "description" => nil,
                 "filename" => "test.jpg",
                 "isActive" => true,
                 "position" => 1,
                 "category" => nil
               }
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
            image {
              description
              filename
              isActive
              position
              category
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "image" => %{
                 "description" => nil,
                 "filename" => "test.jpg",
                 "isActive" => true,
                 "position" => 1,
                 "category" => nil
               }
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
            image {
              description
              filename
              isActive
              position
              category
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert_forbidden_response(json_response(conn, 200))
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
            image {
              description
              filename
              isActive
              position
              category
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert_unauthorized_response(json_response(conn, 200))
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
          filename: "test.jpg",
          category: "kitchen"
        )

      variables = %{
        "input" => [
          %{"id" => id1, "position" => 1, "description" => "waow1", "category" => "bathroom1"},
          %{"id" => id2, "position" => 2, "description" => "waow2", "category" => "bathroom2"},
          %{"id" => id3, "position" => 3, "description" => "waow3", "category" => "bathroom3"}
        ]
      }

      mutation = """
        mutation UpdateImages ($input: ImageUpdateInput!) {
          updateImages(input: $input) {
            parentListing {
              id
            }
            images {
              id
              description
              filename
              isActive
              position
              category
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "parentListing" => %{
                 "id" => to_string(listing_id)
               },
               "images" => [
                 %{
                   "id" => to_string(id1),
                   "description" => "waow1",
                   "filename" => "test.jpg",
                   "isActive" => true,
                   "position" => 1,
                   "category" => "bathroom1"
                 },
                 %{
                   "id" => to_string(id2),
                   "description" => "waow2",
                   "filename" => "test.jpg",
                   "isActive" => true,
                   "position" => 2,
                   "category" => "bathroom2"
                 },
                 %{
                   "id" => to_string(id3),
                   "description" => "waow3",
                   "filename" => "test.jpg",
                   "isActive" => true,
                   "position" => 3,
                   "category" => "bathroom3"
                 }
               ]
             } == json_response(conn, 200)["data"]["updateImages"]

      image1 = Repo.get(Re.Image, id1)
      assert 1 == image1.position
      assert "waow1" == image1.description
      assert "test.jpg" == image1.filename
      assert image1.is_active
      assert "bathroom1" == image1.category

      image2 = Repo.get(Re.Image, id2)
      assert 2 == image2.position
      assert "waow2" == image2.description
      assert "test.jpg" == image2.filename
      assert image2.is_active
      assert "bathroom2" == image2.category

      image3 = Repo.get(Re.Image, id3)
      assert 3 == image3.position
      assert "waow3" == image3.description
      assert "test.jpg" == image3.filename
      assert image3.is_active
      assert "bathroom3" == image3.category
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
          filename: "test.jpg",
          category: "kitchen"
        )

      variables = %{
        "input" => [
          %{"id" => id1, "position" => 1, "description" => "waow1", "category" => "bathroom1"},
          %{"id" => id2, "position" => 2, "description" => "waow2", "category" => "bathroom2"},
          %{"id" => id3, "position" => 3, "description" => "waow3", "category" => "bathroom3"}
        ]
      }

      mutation = """
        mutation UpdateImages ($input: ImageUpdateInput!) {
          updateImages(input: $input) {
            parentListing {
              id
            }
            images {
              id
              description
              filename
              isActive
              position
              category
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "parentListing" => %{
                 "id" => to_string(listing_id)
               },
               "images" => [
                 %{
                   "id" => to_string(id1),
                   "description" => "waow1",
                   "filename" => "test.jpg",
                   "isActive" => true,
                   "position" => 1,
                   "category" => "bathroom1"
                 },
                 %{
                   "id" => to_string(id2),
                   "description" => "waow2",
                   "filename" => "test.jpg",
                   "isActive" => true,
                   "position" => 2,
                   "category" => "bathroom2"
                   },
                 %{
                   "id" => to_string(id3),
                   "description" => "waow3",
                   "filename" => "test.jpg",
                   "isActive" => true,
                   "position" => 3,
                   "category" => "bathroom3"
                 }
               ]
             } == json_response(conn, 200)["data"]["updateImages"]

      image1 = Repo.get(Re.Image, id1)
      assert 1 == image1.position
      assert "waow1" == image1.description
      assert "test.jpg" == image1.filename
      assert image1.is_active
      assert "bathroom1" == image1.category

      image2 = Repo.get(Re.Image, id2)
      assert 2 == image2.position
      assert "waow2" == image2.description
      assert "test.jpg" == image2.filename
      assert image2.is_active
      assert "bathroom2" == image2.category

      image3 = Repo.get(Re.Image, id3)
      assert 3 == image3.position
      assert "waow3" == image3.description
      assert "test.jpg" == image3.filename
      assert image3.is_active
      assert "bathroom3" == image3.category
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
            parentListing {
              id
            }
            images {
              id
              description
              filename
              isActive
              position
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert_forbidden_response(json_response(conn, 200))
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
            parentListing {
              id
            }
            images {
              id
              description
              filename
              isActive
              position
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert_unauthorized_response(json_response(conn, 200))
    end
  end

  describe "deactivate" do
    test "admin should deactivate image", %{admin_conn: conn} do
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
        "input" => %{
          "image_ids" => [id1, id2, id3]
        }
      }

      mutation = """
        mutation ImagesDeactivate ($input: ImageDeactivateInput!) {
          imagesDeactivate(input: $input) {
            images {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "images" => [
                 %{"id" => to_string(id1)},
                 %{"id" => to_string(id2)},
                 %{"id" => to_string(id3)}
               ]
             } == json_response(conn, 200)["data"]["imagesDeactivate"]

      refute Repo.get(Re.Image, id1).is_active
      refute Repo.get(Re.Image, id2).is_active
      refute Repo.get(Re.Image, id3).is_active
    end

    test "admin should not deactivate images from different listings", %{admin_conn: conn} do
      %{id: listing_id1} = insert(:listing)

      [%{id: id1}, %{id: id2}, %{id: id3}] =
        insert_list(
          3,
          :image,
          listing_id: listing_id1,
          position: 5,
          description: "wah",
          filename: "test.jpg",
          is_active: true
        )

      %{id: listing_id2} = insert(:listing)

      [%{id: id4}, %{id: id5}, %{id: id6}] =
        insert_list(
          3,
          :image,
          listing_id: listing_id2,
          position: 5,
          description: "wah",
          filename: "test.jpg",
          is_active: true
        )

      variables = %{
        "input" => %{
          "image_ids" => [id1, id2, id3, id4, id5, id6]
        }
      }

      mutation = """
        mutation ImagesDeactivate ($input: ImageDeactivateInput!) {
          imagesDeactivate(input: $input) {
            images {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "distinct_listings"}] = json_response(conn, 200)["errors"]

      assert Repo.get(Re.Image, id1).is_active
      assert Repo.get(Re.Image, id2).is_active
      assert Repo.get(Re.Image, id3).is_active
      assert Repo.get(Re.Image, id4).is_active
      assert Repo.get(Re.Image, id5).is_active
      assert Repo.get(Re.Image, id6).is_active
    end
  end

  describe "activate" do
    test "admin should activate image", %{admin_conn: conn} do
      %{id: listing_id} = insert(:listing)

      [%{id: id1}, %{id: id2}, %{id: id3}] =
        insert_list(
          3,
          :image,
          listing_id: listing_id,
          position: 5,
          description: "wah",
          filename: "test.jpg",
          is_active: false
        )

      variables = %{
        "input" => %{
          "image_ids" => [id1, id2, id3]
        }
      }

      mutation = """
        mutation ImagesActivate ($input: ImageActivateInput!) {
          imagesActivate(input: $input) {
            images {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "images" => [
                 %{"id" => to_string(id1)},
                 %{"id" => to_string(id2)},
                 %{"id" => to_string(id3)}
               ]
             } == json_response(conn, 200)["data"]["imagesActivate"]

      assert Repo.get(Re.Image, id1).is_active
      assert Repo.get(Re.Image, id2).is_active
      assert Repo.get(Re.Image, id3).is_active
    end

    test "admin should not activate images from different listings", %{admin_conn: conn} do
      %{id: listing_id1} = insert(:listing)

      [%{id: id1}, %{id: id2}, %{id: id3}] =
        insert_list(
          3,
          :image,
          listing_id: listing_id1,
          position: 5,
          description: "wah",
          filename: "test.jpg",
          is_active: false
        )

      %{id: listing_id2} = insert(:listing)

      [%{id: id4}, %{id: id5}, %{id: id6}] =
        insert_list(
          3,
          :image,
          listing_id: listing_id2,
          position: 5,
          description: "wah",
          filename: "test.jpg",
          is_active: false
        )

      variables = %{
        "input" => %{
          "image_ids" => [id1, id2, id3, id4, id5, id6]
        }
      }

      mutation = """
        mutation ImagesActivate ($input: ImageActivateInput!) {
          imagesActivate(input: $input) {
            images {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "distinct_listings"}] = json_response(conn, 200)["errors"]

      refute Repo.get(Re.Image, id1).is_active
      refute Repo.get(Re.Image, id2).is_active
      refute Repo.get(Re.Image, id3).is_active
      refute Repo.get(Re.Image, id4).is_active
      refute Repo.get(Re.Image, id5).is_active
      refute Repo.get(Re.Image, id6).is_active
    end
  end
end
