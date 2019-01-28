defmodule ReWeb.GraphQL.Listings.SubscriptionTest do
  use ReWeb.SubscriptionCase

  import Re.Factory

  describe "listingUpdated" do
    test "admin should subscribe to updateListing", %{
      admin_socket: admin_socket
    } do
      %{id: address_id} = insert(:address)
      listing = insert(:listing, type: "Apartamento", address_id: address_id)

      ref = push_doc(admin_socket, build_subscription("listingUpdated", listing.id))

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      mutation = """
        mutation {
          updateListing(
          id: #{listing.id},
          input: {
            type: "Casa",
            addressId: #{address_id}
          }) {
            id
            type
          }
        }
      """

      ref = push_doc(admin_socket, mutation)

      assert_reply(
        ref,
        :ok,
        %{data: %{"updateListing" => %{"id" => listing_id, "type" => "Casa"}}},
        3000
      )

      expected = %{
        result: %{
          data: %{
            "listingUpdated" => %{"id" => listing_id, "type" => "Casa"}
          }
        },
        subscriptionId: subscription_id
      }

      assert_push("subscription:data", push)
      assert expected == push
    end

    test "user should not subscribe to updateListing", %{
      user_socket: user_socket
    } do
      ref = push_doc(user_socket, build_subscription("listingUpdated", 1))

      assert_reply(ref, :error, %{errors: [%{message: :unauthorized}]})
    end

    test "anonymous should not subscribe to updateListing", %{
      unauthenticated_socket: unauthenticated_socket
    } do
      ref = push_doc(unauthenticated_socket, build_subscription("listingUpdated", 1))

      assert_reply(ref, :error, %{errors: [%{message: :unauthenticated}]})
    end
  end

  describe "listingInserted" do
    test "admin should subscribe to insertListing", %{
      admin_socket: admin_socket
    } do
      %{id: address_id} = insert(:address)

      ref = push_doc(admin_socket, build_subscription("listingInserted"))

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      mutation = """
        mutation {
          insertListing(
            input: {
              type: "Casa",
              addressId: #{address_id}
          }) {
            id
            type
          }
        }
      """

      ref = push_doc(admin_socket, mutation)

      assert_reply(
        ref,
        :ok,
        %{data: %{"insertListing" => %{"id" => listing_id, "type" => "Casa"}}},
        3000
      )

      expected = %{
        result: %{
          data: %{
            "listingInserted" => %{"id" => listing_id, "type" => "Casa"}
          }
        },
        subscriptionId: subscription_id
      }

      assert_push("subscription:data", push)
      assert expected == push
    end

    test "user should not subscribe to insertListing", %{
      user_socket: user_socket
    } do
      ref = push_doc(user_socket, build_subscription("listingInserted"))

      assert_reply(ref, :error, %{errors: [%{message: :unauthorized}]})
    end

    test "anonymous should not subscribe to insertListing", %{
      unauthenticated_socket: unauthenticated_socket
    } do
      ref = push_doc(unauthenticated_socket, build_subscription("listingInserted"))

      assert_reply(ref, :error, %{errors: [%{message: :unauthenticated}]})
    end
  end

  describe "listingActivated" do
    test "admin should subscribe to activateListing", %{
      admin_socket: admin_socket
    } do
      %{id: address_id} = insert(:address)
      listing = insert(:listing, type: "Apartamento", address_id: address_id, status: "inactive")

      ref = push_doc(admin_socket, build_subscription("listingActivated", listing.id))

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      mutation = """
        mutation {
          activateListing(id: #{listing.id}) {
            id
            type
          }
        }
      """

      ref = push_doc(admin_socket, mutation)

      assert_reply(
        ref,
        :ok,
        %{data: %{"activateListing" => %{"id" => listing_id, "type" => "Apartamento"}}},
        3000
      )

      expected = %{
        result: %{
          data: %{
            "listingActivated" => %{"id" => listing_id, "type" => "Apartamento"}
          }
        },
        subscriptionId: subscription_id
      }

      assert_push("subscription:data", push)
      assert expected == push
    end

    test "user should not subscribe to activateListing", %{
      user_socket: user_socket
    } do
      ref = push_doc(user_socket, build_subscription("listingActivated", 1))

      assert_reply(ref, :error, %{errors: [%{message: :unauthorized}]})
    end

    test "anonymous should not subscribe to activateListing", %{
      unauthenticated_socket: unauthenticated_socket
    } do
      ref = push_doc(unauthenticated_socket, build_subscription("listingActivated", 1))

      assert_reply(ref, :error, %{errors: [%{message: :unauthenticated}]})
    end
  end

  describe "listingDeactivated" do
    test "admin should subscribe to deactivateListing", %{
      admin_socket: admin_socket
    } do
      %{id: address_id} = insert(:address)
      listing = insert(:listing, type: "Apartamento", address_id: address_id, status: "active")

      ref = push_doc(admin_socket, build_subscription("listingDeactivated", listing.id))

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      mutation = """
        mutation {
          deactivateListing(id: #{listing.id}) {
            id
            type
          }
        }
      """

      ref = push_doc(admin_socket, mutation)

      assert_reply(
        ref,
        :ok,
        %{data: %{"deactivateListing" => %{"id" => listing_id, "type" => "Apartamento"}}},
        3000
      )

      expected = %{
        result: %{
          data: %{
            "listingDeactivated" => %{"id" => listing_id, "type" => "Apartamento"}
          }
        },
        subscriptionId: subscription_id
      }

      assert_push("subscription:data", push)
      assert expected == push
    end

    test "user should not subscribe to deactivateListing", %{
      user_socket: user_socket
    } do
      ref = push_doc(user_socket, build_subscription("listingDeactivated", 1))

      assert_reply(ref, :error, %{errors: [%{message: :unauthorized}]})
    end

    test "anonymous should not subscribe to deactivateListing", %{
      unauthenticated_socket: unauthenticated_socket
    } do
      ref = push_doc(unauthenticated_socket, build_subscription("listingDeactivated", 1))

      assert_reply(ref, :error, %{errors: [%{message: :unauthenticated}]})
    end
  end

  defp build_subscription(name) do
    """
     subscription {
       #{name} {
         id
         type
       }
     }
    """
  end

  defp build_subscription(name, listing_id) do
    """
     subscription {
       #{name}(id: #{listing_id}) {
         id
         type
       }
     }
    """
  end
end
