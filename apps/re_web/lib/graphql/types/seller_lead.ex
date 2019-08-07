defmodule ReWeb.Types.SellerLead do
  @moduledoc """
  GraphQL types for seller leads
  """
  use Absinthe.Schema.Notation

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
    field :owner_name, non_null(:string)
    field :owner_telephone, non_null(:string)
    field :owner_email, :string
    field :address, non_null(:address_input)
    field :campaign, :string
    field :medium, :string
    field :source, :string
    field :initial_campaign, :string
    field :initial_medium, :string
    field :initial_source, :string
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
  end
end
