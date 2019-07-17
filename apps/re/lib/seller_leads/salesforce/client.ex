defmodule Re.SellerLeads.Salesforce.Client do
  @moduledoc """
  Module to interface with salesforce
  """

  alias Re.{
    Address,
    SellerLeads.Salesforce.ZapierClient,
    User
  }

  @exported ~w(uuid source type complement price rooms bathrooms suites garage_spots
               maintenance_fee area tour_option inserted_at)a

  def create_lead(%Re.SellerLead{} = lead) do
    lead
    |> Map.take(@exported)
    |> put_user_params(lead.user)
    |> put_address_params(lead.address)
    |> Map.update(:phone, "", fn phone -> String.replace(phone, "+", "") end)
    |> Jason.encode!()
    |> ZapierClient.post()
    |> case do
      {:ok, %{status_code: 200, body: body}} -> Jason.decode(body)
      error -> error
    end
  end

  def create_lead(_), do: {:error, :lead_type_not_handled}

  defp put_user_params(params, %User{} = user) do
    user
    |> Map.take(~w(name phone email)a)
    |> Map.merge(params)
  end

  defp put_address_params(params, %Address{} = address) do
    address
    |> Map.take(~w(street street_number city state neighborhood postal_code)a)
    |> Map.merge(params)
  end
end
