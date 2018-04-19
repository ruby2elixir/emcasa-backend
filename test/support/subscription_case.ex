defmodule ReWeb.SubscriptionCase do
  @moduledoc """
  This module defines the test case to be used by
  subscription tests
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      use ReWeb.ChannelCase
      use Absinthe.Phoenix.SubscriptionTest, schema: ReWeb.Schema

      import Re.Factory

      alias ReWeb.Guardian

      setup do
        {:ok, unauthenticated_socket} = Phoenix.ChannelTest.connect(ReWeb.UserSocket, %{})
        {:ok, unauthenticated_socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(unauthenticated_socket)

        admin = insert(:user, email: "admin@email.com", role: "admin")
        {:ok, admin_jwt, _full_claims} = Guardian.encode_and_sign(admin)

        {:ok, admin_socket} =
          Phoenix.ChannelTest.connect(ReWeb.UserSocket, %{
            "Authorization" => "Token " <> admin_jwt
          })

        {:ok, admin_socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(admin_socket)

        user = insert(:user, email: "user@email.com", role: "user")
        {:ok, user_jwt, _full_claims} = Guardian.encode_and_sign(user)

        {:ok, user_socket} =
          Phoenix.ChannelTest.connect(ReWeb.UserSocket, %{"Authorization" => "Token " <> user_jwt})

        {:ok, user_socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(user_socket)

        {:ok,
         unauthenticated_socket: unauthenticated_socket,
         admin_user: admin,
         user_user: user,
         admin_socket: admin_socket,
         user_socket: user_socket}
      end
    end
  end
end
