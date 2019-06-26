defmodule Re.BuyerLeads.Salesforce.Client do
  @moduledoc """
  Module to interface with salesforce
  """

  alias Re.BuyerLeads.Salesforce.ZapierClient

  def create_lead(%Re.BuyerLead{} = lead) do
    with lead <- take_params(lead),
         {:ok, payload} <- Jason.encode(lead),
         {:ok, %{status_code: 200, body: body}} <- ZapierClient.post(payload) do
      Jason.decode(body)
    end
  end

  def create_lead(_lead), do: {:error, :lead_type_not_handled}

  @exported ~w(uuid name phone_number origin email location listing_uuid user_uuid budget neighborhood url user_url)a

  defp take_params(lead), do: Map.take(lead, @exported)
end
