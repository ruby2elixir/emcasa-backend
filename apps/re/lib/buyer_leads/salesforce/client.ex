defmodule Re.BuyerLeads.Salesforce.Client do
  @moduledoc """
  Module to interface with salesforce
  """

  alias Re.BuyerLeads.Salesforce.ZapierClient

  @exported ~w(uuid name phone_number origin email location listing_uuid user_uuid budget
               neighborhood url user_url cpf where_did_you_find_about)a

  def create_lead(%Re.BuyerLead{} = lead) do
    lead
    |> Map.take(@exported)
    |> Map.update(:phone_number, "", fn phone -> String.replace(phone, "+", "") end)
    |> Jason.encode!()
    |> ZapierClient.post()
    |> case do
      {:ok, %{status_code: 200, body: body}} -> Jason.decode(body)
      error -> error
    end
  end

  def create_lead(_lead), do: {:error, :lead_type_not_handled}
end
