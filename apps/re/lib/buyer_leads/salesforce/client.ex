defmodule Re.BuyerLeads.Salesforce.Client do
  @moduledoc """
  Module to interface with salesforce
  """

  alias Re.BuyerLeads.Salesforce.ZapierClient

  def create_lead(%Re.BuyerLead{} = lead) do
    with {:ok, payload} <- Jason.encode(lead),
         {:ok, %{status_code: 200, body: body}} <- ZapierClient.post(payload) do
      Jason.decode(body)
    end
  end

  def create_lead(_lead), do: {:error, :lead_type_not_handled}
end
