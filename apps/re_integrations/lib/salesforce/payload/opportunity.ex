defmodule ReIntegrations.Salesforce.Payload.Opportunity do
  @moduledoc """
  Module for validating salesforce opportunity entity
  """
  use Ecto.Schema

  import Ecto.Changeset

  import EctoEnum

  defenum(TourPeriod,
    morning: "Manhã: 09h - 12h",
    afternoon: "Tarde: 12h - 18h"
  )

  @primary_key {:id, :string, []}

  @doc """
  Maps salesforce fields to atoms for internal use
  """
  defenum(Schema,
    id: "Id",
    account_id: "AccountId",
    owner_id: "OwnerId",
    address: "Dados_do_Imovel_para_Venda__c",
    neighborhood: "Bairro__c",
    tour_date: "Data_Tour__c",
    tour_period: "Faixa_Hor_ria_Tour__c"
  )

  schema "salesforce_opportunity" do
    field :account_id, :string
    field :owner_id, :string
    field :address, :string
    field :neighborhood, :string
    field :tour_date, :naive_datetime
    field :tour_period, TourPeriod
  end

  @params ~w(id account_id owner_id address neighborhood tour_date tour_period)a

  def build(payload) do
    payload
    |> Enum.into(%{}, &build_field/1)
    |> validate()
  end

  defp build_field({field, value}),
    do: with({:ok, key} <- Schema.cast(field), do: {key, value})

  def validate(params) do
    %__MODULE__{}
    |> changeset(params)
    |> case do
      %{valid?: true} = changeset -> {:ok, apply_changes(changeset)}
      changeset -> {:error, :invalid_input, params, changeset}
    end
  end

  defp changeset(struct, params), do: struct |> cast(params, @params)

  def visitation_period(%{tour_date: %NaiveDateTime{} = tour_date}),
    do: %{start: tour_date |> NaiveDateTime.to_time(), end: tour_date |> NaiveDateTime.to_time()}

  def visitation_period(%{tour_period: :morning}), do: %{start: ~T[09:00:00Z], end: ~T[12:00:00Z]}

  def visitation_period(%{tour_period: :afternoon}),
    do: %{start: ~T[12:00:00Z], end: ~T[18:00:00Z]}

  def visitation_period(_), do: %{start: ~T[09:00:00Z], end: ~T[18:00:00Z]}
end
