defmodule ReWeb.Types.Interest do
  @moduledoc """
  GraphQL types for interests
  """
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias ReWeb.Resolvers.Interests, as: InterestsResolver

  object :contact do
    field :id, :id
    field :name, :string
    field :email, :string
    field :phone, :string
    field :message, :string

    field :user, :user, resolve: dataloader(Re.Accounts)
  end

  object :price_request do
    field :id, :id
    field :name, :string
    field :email, :string
    field :area, :integer
    field :rooms, :integer
    field :bathrooms, :integer
    field :garage_spots, :integer
    field :is_covered, :boolean
    field :suggested_price, :float

    field :address, :address, resolve: dataloader(Re.Addresses)
    field :user, :user, resolve: dataloader(Re.Accounts)
  end

  object :interest_mutations do
    @desc "Request contact"
    field :request_contact, type: :contact do
      arg :name, :string
      arg :phone, :string
      arg :email, :string
      arg :message, :string

      resolve &InterestsResolver.request_contact/2
    end

    @desc "Request price suggestion"
    field :request_price_suggestion, type: :price_request do
      arg :name, non_null(:string)
      arg :email, non_null(:string)
      arg :area, non_null(:integer)
      arg :rooms, non_null(:integer)
      arg :bathrooms, non_null(:integer)
      arg :garage_spots, non_null(:integer)
      arg :is_covered, non_null(:boolean)

      arg :address, non_null(:address_input)

      resolve &InterestsResolver.request_price_suggestion/2
    end
  end

  object :interest_subscriptions do
    @desc "Subscribe to email change"
    field :contact_requested, :contact do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "contact_requested"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :request_contact,
        topic: fn _ ->
          "contact_requested"
        end
    end

    @desc "Subscribe to price suggestion requests"
    field :price_suggestion_requested, :price_request do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "price_suggestion_requested"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :request_price_suggestion,
        topic: fn _ ->
          "price_suggestion_requested"
        end
    end
  end
end
