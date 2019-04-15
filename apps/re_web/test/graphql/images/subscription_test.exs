defmodule ReWeb.GraphQL.Images.SubscriptionTest do
  use ReWeb.SubscriptionCase

  @activation_subscriptions [
    {"imagesDeactivated", "imagesDeactivate"}
  ]

  import Re.Factory

  Enum.each(@activation_subscriptions, fn {subscription, mutation} ->
    @subscription subscription
    @mutation mutation

    test "admin should subscribe to #{@mutation}", %{
      admin_socket: admin_socket
    } do
      %{id: listing_id} = insert(:listing)
      ref = push_doc(admin_socket, build_subscription(@subscription, listing_id))

      [%{id: id1}, %{id: id2}, %{id: id3}] =
        insert_list(
          3,
          :image,
          listing_id: listing_id,
          position: 5,
          description: "wah",
          filename: "test.jpg",
          is_active: true
        )

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      mutation = """
        mutation {
          #{@mutation}(input: {
            imageIds: [#{id1},#{id2},#{id3}]
          }) {
            images {
              id
            }
          }
        }
      """

      ref = push_doc(admin_socket, mutation)

      assert_reply(
        ref,
        :ok,
        %{
          data: %{
            @mutation => %{
              "images" => [
                %{"id" => id1},
                %{"id" => id2},
                %{"id" => id3}
              ]
            }
          }
        },
        3000
      )

      expected = %{
        result: %{
          data: %{
            @subscription => %{
              "images" => [
                %{"id" => id1, "position" => 5, "description" => "wah"},
                %{"id" => id2, "position" => 5, "description" => "wah"},
                %{"id" => id3, "position" => 5, "description" => "wah"}
              ]
            }
          }
        },
        subscriptionId: subscription_id
      }

      assert_push("subscription:data", push)
      assert expected == push
    end

    test "user should not subscribe to #{@mutation}", %{
      user_socket: user_socket
    } do
      ref = push_doc(user_socket, build_subscription(@subscription, 1))

      assert_reply(ref, :error, %{errors: [%{message: :unauthorized}]})
    end

    test "anonymous should not subscribe to #{@mutation}", %{
      unauthenticated_socket: unauthenticated_socket
    } do
      ref = push_doc(unauthenticated_socket, build_subscription(@subscription, 1))

      assert_reply(ref, :error, %{errors: [%{message: :unauthenticated}]})
    end
  end)

  describe "imagesUpdated" do
    test "admin should subscribe to updateImages", %{
      admin_socket: admin_socket
    } do
      %{id: listing_id} = insert(:listing)
      ref = push_doc(admin_socket, build_subscription("imagesUpdated", listing_id))

      [%{id: id1}, %{id: id2}, %{id: id3}] =
        insert_list(
          3,
          :image,
          listing_id: listing_id,
          position: 5,
          description: "wah1",
          filename: "test.jpg",
          is_active: true
        )

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      mutation = """
        mutation {
          updateImages(input: [
            {id: #{id1}, position: 4, description: "wah2"},
            {id: #{id2}, position: 4, description: "wah2"},
            {id: #{id3}, position: 4, description: "wah2"}
          ]) {
            images {
              id
              position
              description
            }
          }
        }
      """

      ref = push_doc(admin_socket, mutation)

      assert_reply(
        ref,
        :ok,
        %{
          data: %{
            "updateImages" => %{
              "images" => [
                %{"id" => id1, "position" => 4, "description" => "wah2"},
                %{"id" => id2, "position" => 4, "description" => "wah2"},
                %{"id" => id3, "position" => 4, "description" => "wah2"}
              ]
            }
          }
        },
        3000
      )

      expected = %{
        result: %{
          data: %{
            "imagesUpdated" => %{
              "images" => [
                %{"id" => id1, "position" => 4, "description" => "wah2"},
                %{"id" => id2, "position" => 4, "description" => "wah2"},
                %{"id" => id3, "position" => 4, "description" => "wah2"}
              ]
            }
          }
        },
        subscriptionId: subscription_id
      }

      assert_push("subscription:data", push)
      assert expected == push
    end

    test "user should not subscribe to updateImages", %{
      user_socket: user_socket
    } do
      ref = push_doc(user_socket, build_subscription("imagesUpdated", 1))

      assert_reply(ref, :error, %{errors: [%{message: :unauthorized}]})
    end

    test "anonymous should not subscribe to updateImages", %{
      unauthenticated_socket: unauthenticated_socket
    } do
      ref = push_doc(unauthenticated_socket, build_subscription("imagesUpdated", 1))

      assert_reply(ref, :error, %{errors: [%{message: :unauthenticated}]})
    end
  end

  describe "imageInserted" do
    test "admin should subscribe to insertImage", %{
      admin_socket: admin_socket
    } do
      %{id: listing_id} = insert(:listing)

      ref =
        push_doc(admin_socket, """
          subscription {
            imageInserted(listingId: #{listing_id}) {
              image {
                id
                filename
              }
              parentListing {
                id
              }
            }
          }
        """)

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      mutation = """
        mutation {
          insertImage(
            input: {listingId: #{listing_id}, filename: "filename.jpeg"}
          ) {
            image {
              id
              filename
            }
            parentListing {
              id
            }
          }
        }
      """

      ref = push_doc(admin_socket, mutation)

      assert_reply(
        ref,
        :ok,
        %{
          data: %{
            "insertImage" => %{
              "image" => %{"id" => id1, "filename" => "filename.jpeg"},
              "parentListing" => %{"id" => listing_id}
            }
          }
        },
        3000
      )

      expected = %{
        result: %{
          data: %{
            "imageInserted" => %{
              "image" => %{"id" => id1, "filename" => "filename.jpeg"},
              "parentListing" => %{"id" => listing_id}
            }
          }
        },
        subscriptionId: subscription_id
      }

      assert_push("subscription:data", push)
      assert expected == push
    end

    test "user should not subscribe to insertImage", %{
      user_socket: user_socket
    } do
      ref =
        push_doc(user_socket, """
          subscription {
            imageInserted(listingId: 1) {
              image {
                id
                filename
              }
              parentListing {
                id
              }
            }
          }
        """)

      assert_reply(ref, :error, %{errors: [%{message: :unauthorized}]})
    end

    test "anonymous should not subscribe to insertImage", %{
      unauthenticated_socket: unauthenticated_socket
    } do
      ref =
        push_doc(unauthenticated_socket, """
          subscription {
            imageInserted(listingId: 1) {
              image {
                id
                filename
              }
              parentListing {
                id
              }
            }
          }
        """)

      assert_reply(ref, :error, %{errors: [%{message: :unauthenticated}]})
    end
  end

  defp build_subscription(name, listing_id) do
    """
     subscription {
       #{name}(listingId: #{listing_id}) {
         images {
           id
           position
           description
         }
       }
     }
    """
  end
end
