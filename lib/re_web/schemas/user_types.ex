defmodule ReWeb.Schema.UserTypes do
  @moduledoc """
  GraphQL types for users
  """
  use Absinthe.Schema.Notation

  alias Re.{
    Listing,
    User
  }

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
    field :phone, :string
    field :role, :string
  end

  object :message do
    field :id, :id
    field :message, :string
    field :read, :boolean
    field :notified, :boolean

    field :sender, :user do
      resolve fn message, _, _ ->
        batch(
          {ReWeb.Schema.Helpers, :by_id, User},
          message.sender_id,
          &{:ok, Map.get(&1, message.sender_id)}
        )
      end
    end

    field :receiver, :user do
      resolve fn message, _, _ ->
        batch(
          {ReWeb.Schema.Helpers, :by_id, User},
          message.receiver_id,
          &{:ok, Map.get(&1, message.receiver_id)}
        )
      end
    end

    field :listing, :listing do
      resolve fn message, _, _ ->
        batch(
          {ReWeb.Schema.Helpers, :by_id, Listing},
          message.listing_id,
          &{:ok, Map.get(&1, message.listing_id)}
        )
      end
    end
  end
end
