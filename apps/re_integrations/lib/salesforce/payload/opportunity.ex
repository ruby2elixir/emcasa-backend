defmodule ReIntegrations.Salesforce.Payload.Opportunity do
  @moduledoc """
  Module for validating salesforce opportunity entity
  """
  use Ecto.Schema

  import Ecto.Changeset

  import EctoEnum

  defenum(TourPeriod,
    morning: "Manhã",
    afternoon: "Tarde",
    flexible: "Flexível",
    strict: "Fixo"
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
    notes: "Comentarios_do_Agendamento__c",
    tour_strict_date: "Data_Fixa_para_o_Tour__c",
    tour_strict_time: "Horario_Fixo_para_o_Tour__c",
    tour_period: "Periodo_Disponibilidade_Tour__c"
  )

  schema "salesforce_opportunity" do
    field :account_id, :string
    field :owner_id, :string
    field :address, :string
    field :neighborhood, :string
    field :notes, :string
    field :tour_strict_date, :date
    field :tour_strict_time, :time
    field :tour_period, TourPeriod
  end

  @params ~w(id account_id owner_id address neighborhood tour_strict_date tour_strict_time tour_period)a

  def build(payload) do
    payload
    |> Map.take(Schema.__valid_values__())
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

  defp changeset(struct, params), do: cast(struct, params, @params)

  def visit_start_window(%{tour_period: :strict, tour_strict_time: %Time{} = time}),
    do: %{start: time, end: time}

  def visit_start_window(%{tour_period: :morning}),
    do: %{start: ~T[09:00:00Z], end: ~T[12:00:00Z]}

  def visit_start_window(%{tour_period: :afternoon}),
    do: %{start: ~T[12:00:00Z], end: ~T[18:00:00Z]}

  def visit_start_window(%{tour_period: :flexible}),
    do: %{start: ~T[09:00:00Z], end: ~T[18:00:00Z]}

  def visit_start_window(_), do: visit_start_window(%{tour_period: :flexible})
end
