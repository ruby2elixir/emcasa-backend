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

  input_object :site_seller_lead_input do
    field :complement, :string
    field :type, :string
    field :price, :integer
    field :maintenance_fee, :float
    field :suites, :integer
    field :price_request_id, non_null(:id)
  end

  object :seller_lead_mutations do
    @desc "Insert seller lead"
    field :site_seller_lead_create, type: :site_seller_lead do
      arg :input, non_null(:site_seller_lead_input)

      resolve &Resolvers.SellerLeads.create_site/2
    end
  end
end
