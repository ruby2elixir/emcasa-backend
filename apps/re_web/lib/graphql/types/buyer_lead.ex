defmodule ReWeb.Types.BuyerLead do
  @moduledoc """
  GraphQL types for buyer leads
  """
  use Absinthe.Schema.Notation

  alias ReWeb.Resolvers

  input_object :budget_buyer_lead_input do
    field :city, non_null(:string)
    field :state, non_null(:string)
    field :neighborhood, non_null(:string)
    field :budget, non_null(:string)
  end

  object :buyer_lead_mutations do
    @desc "Insert buyer lead"
    field :budget_buyer_lead_create, type: :async_response do
      arg :input, non_null(:budget_buyer_lead_input)

      resolve &Resolvers.BuyerLeads.create_budget/2
    end
  end
end
