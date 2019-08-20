defmodule ReWeb.Types.Interest do
  @moduledoc """
  GraphQL types for interests
  """
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias ReWeb.Resolvers.Interests, as: InterestsResolver

  object :interest do
    field :id, :id
    field :uuid, :uuid
    field :name, :string
    field :email, :string
    field :phone, :string
    field :message, :string
    field :campaign, :string
    field :medium, :string
    field :source, :string
    field :initial_campaign, :string
    field :initial_medium, :string
    field :initial_source, :string

    field :listing, :listing, resolve: dataloader(Re.Listings)
  end

  input_object :interest_input do
    field :name, :string
    field :phone, :string
    field :email, :string
    field :message, :string
    field :campaign, :string
    field :medium, :string
    field :source, :string
    field :initial_campaign, :string
    field :initial_medium, :string
    field :initial_source, :string

    field :interest_type_id, :id

    field :listing_id, non_null(:id)
  end

  object :contact do
    field :id, :id
    field :name, :string
    field :email, :string
    field :phone, :string
    field :message, :string

    field :state, :string
    field :city, :string
    field :neighborhood, :string
  end

  object :simulation do
    field :cem, :string
    field :cet, :string
  end

  input_object :simulation_request do
    field :mutuary, non_null(:string)
    field :birthday, non_null(:date)
    field :include_coparticipant, non_null(:boolean)
    field :net_income, non_null(:decimal)
    field :net_income_coparticipant, :decimal
    field :birthday_coparticipant, :date
    field :fundable_value, non_null(:decimal)
    field :term, non_null(:integer)
    field :amortization, :boolean
    field :annual_interest, :float
    field :home_equity_annual_interest, :float
    field :calculate_tr, :boolean
    field :evaluation_rate, :decimal
    field :itbi_value, :decimal
    field :listing_price, :decimal
    field :listing_type, :string
    field :product_type, :string
    field :sum, :boolean
    field :insurer, :string
  end

  object :interest_queries do
    @desc "Request funding simulation"
    field :simulate, type: :simulation do
      arg :input, non_null(:simulation_request)

      resolve &InterestsResolver.simulate/2
    end
  end

  object :interest_mutations do
    @desc "Show interest in listing"
    field :interest_create, type: :interest do
      arg :input, non_null(:interest_input)

      resolve &InterestsResolver.create_interest/2
    end

    @desc "Request contact"
    field :request_contact, type: :contact do
      arg :name, :string
      arg :phone, :string
      arg :email, :string
      arg :message, :string

      resolve &InterestsResolver.request_contact/2
    end
  end

  object :interest_subscriptions do
    @desc "Subscribe to email change"
    field :interest_created, :interest do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "interest_created"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :interest_create,
        topic: fn _ ->
          "interest_created"
        end
    end

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
  end
end
