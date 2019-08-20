defmodule ReWeb.Types.SellerLead do
  @moduledoc """
  GraphQL types for seller leads
  """
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias ReWeb.Resolvers

  object :site_seller_lead do
    field :uuid, :uuid
    field :complement, :string
    field :type, :string
    field :price, :integer
    field :maintenance_fee, :float
    field :suites, :integer
  end

  object :broker_seller_lead do
    field :uuid, :uuid
  end

  input_object :site_seller_lead_input do
    field :complement, :string
    field :type, :string
    field :price, :integer
    field :maintenance_fee, :float
    field :suites, :integer
    field :price_request_id, non_null(:id)
  end

  input_object :broker_seller_lead_input do
    field :complement, :string
    field :type, non_null(:string)
    field :additional_information, :string
    field :owner, non_null(:owner_contact_input)
    field :address, non_null(:address_input)
    field :utm, :input_utm
  end

  object :price_request do
    field :id, :id
    field :name, :string
    field :email, :string
    field :area, :integer
    field :rooms, :integer
    field :suites, :integer
    field :type, :string
    field :maintenance_fee, :float
    field :bathrooms, :integer
    field :garage_spots, :integer
    field :is_covered, :boolean
    field :suggested_price, :float
    field :listing_price_rounded, :float
    field :listing_price_error_q90_min, :float
    field :listing_price_error_q90_max, :float
    field :listing_price_per_sqr_meter, :float
    field :listing_average_price_per_sqr_meter, :float

    field :address, :address, resolve: dataloader(Re.Addresses)
    field :user, :user, resolve: dataloader(Re.Accounts)
  end

  input_object :price_suggestion_input do
    field :area, non_null(:integer)
    field :rooms, non_null(:integer)
    field :bathrooms, non_null(:integer)
    field :garage_spots, non_null(:integer)
    field :suites, non_null(:integer)
    field :type, non_null(:string)
    field :maintenance_fee, non_null(:float)
    field :address, non_null(:address_input)
  end

  object :seller_lead_mutations do
    @desc "Insert seller lead"
    field :site_seller_lead_create, type: :site_seller_lead do
      arg :input, non_null(:site_seller_lead_input)

      resolve &Resolvers.SellerLeads.create_site/2
    end

    @desc "Insert broker seller lead"
    field :broker_seller_lead_create, type: :broker_seller_lead do
      arg :input, non_null(:broker_seller_lead_input)

      resolve &Resolvers.SellerLeads.create_broker/2
    end

    @desc "Request price suggestion"
    field :request_price_suggestion, type: :price_request do
      arg :name, :string
      arg :email, :string
      arg :area, non_null(:integer)
      arg :rooms, non_null(:integer)
      arg :bathrooms, non_null(:integer)
      arg :garage_spots, non_null(:integer)
      arg :suites, :integer
      arg :type, :string
      arg :maintenance_fee, :float
      arg :is_covered, non_null(:boolean)

      arg :address, non_null(:address_input)

      resolve &Resolvers.SellerLeads.create_price_suggestion/2
    end

    @desc "Request notification when covered"
    field :notify_when_covered, type: :contact do
      arg :name, :string
      arg :phone, :string
      arg :email, :string
      arg :message, :string

      arg :state, non_null(:string)
      arg :city, non_null(:string)
      arg :neighborhood, non_null(:string)

      resolve &Resolvers.SellerLeads.create_out_of_coverage/2
    end
  end

  object :seller_lead_subscriptions do
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

    @desc "Subscribe to price suggestion requests"
    field :notification_coverage_asked, :contact do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "notification_coverage_asked"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :notify_when_covered,
        topic: fn _ ->
          "notification_coverage_asked"
        end
    end
  end
end
