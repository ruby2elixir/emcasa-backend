defmodule Re.SellerLeads.Salesforce do
  @moduledoc """
  Module to interface with salesforce
  """

  alias Re.{
    Address,
    Salesforce.Client,
    Salesforce.Lead,
    User
  }

  @record_type_id Application.get_env(:re_integrations, :salesforce_seller_lead_record_id, "")

  def create_lead(%Re.SellerLead{} = lead) do
    with {:ok, lead} <- map_params(lead, true),
         {:ok, %{body: body}} <- Client.insert_lead(lead) do
      Jason.decode(body)
    end
  end

  def create_lead(_), do: {:error, :lead_type_not_handled}

  def update_lead(%Re.SellerLead{} = lead) do
    with {:ok, salesforce_lead} <- map_params(lead, false),
         {:ok, %{body: body}} <- Client.update_lead(salesforce_lead, lead.salesforce_id) do
      Jason.decode(body)
    end
  end

  def update_lead(_), do: {:error, :lead_type_not_handled}

  defp map_params(lead, evaluation) do
    %{
      uuid: lead.uuid,
      evaluation: evaluation,
      record_type_id: @record_type_id,
      type: :seller,
      realty_type: lead.type,
      complement: lead.complement,
      price: lead.price || lead.suggested_price,
      realty_rooms: lead.rooms,
      realty_bathrooms: lead.bathrooms,
      realty_suites: lead.suites,
      realty_garage_spots: lead.garage_spots,
      maintenance_fee: lead.maintenance_fee,
      area: lead.area,
      tour_data: lead.tour_option,
      inserted_at: lead.inserted_at,
      source: lead.source,
      duplicated: lead.duplicated,
    }
    |> put_user_params(lead.user)
    |> put_address_params(lead.address)
    |> put_duplicated_entities(lead.duplicated_entities)
    |> Lead.validate()
  end

  defp put_user_params(params, %User{} = user) do
    Map.merge(params, %{
      last_name: user.name || "unknown",
      full_name: user.name,
      phone: String.replace(user.phone, "+", ""),
      email: user.email
    })
  end

  defp put_address_params(params, %Address{} = address) do
    Map.merge(params, %{
      location: "#{address.city_slug}|#{address.state_slug}",
      street: address.street,
      realty_street: address.street,
      city: address.city,
      realty_city: address.city,
      state: address.state,
      realty_state: address.state,
      postal_code: address.postal_code,
      realty_postal_code: address.postal_code,
      neighborhood: address.neighborhood,
      realty_street_number: address.street_number
    })
  end

  defp put_duplicated_entities(params, nil), do: params
  defp put_duplicated_entities(params, duplicated_entities) do
    Map.merge(params, %{
      duplicated_entities: Jason.encode!(duplicated_entities)
    })
  end
end
