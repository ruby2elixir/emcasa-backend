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

  defenum(Stage,
    visit_pending: "Confirmação Visita",
    visit_scheduled: "Visita agendada"
  )

  @primary_key {:id, :string, []}

  @doc """
  Maps salesforce fields to atoms for internal use
  """
  defenum(Schema,
    id: "Id",
    account_id: "AccountId",
    owner_id: "OwnerId",
    stage: "StageName",
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
    field :stage, Stage
  end

  @params ~w(id account_id owner_id address neighborhood tour_strict_date tour_strict_time
             tour_period stage notes)a

  def build_all(list) do
    results = Enum.map(list, &with({:ok, value} <- build(&1), do: value))

    with nil <- Enum.find(results, nil, &(not is_ok(&1))), do: {:ok, results}
  end

  defp is_ok({:error, _}), do: false
  defp is_ok({:error, _, _, _, _}), do: false
  defp is_ok(_), do: true

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

defimpl Jason.Encoder, for: ReIntegrations.Salesforce.Payload.Opportunity do
  alias ReIntegrations.Salesforce.Payload.Opportunity

  def encode(value, opts) do
    value
    |> Map.take(keys())
    |> Map.drop([:id])
    |> Enum.filter(&(not is_nil(elem(&1, 1))))
    |> Enum.into(%{}, &dump_field/1)
    |> Jason.Encode.map(opts)
  end

  defp keys, do: Keyword.keys(Opportunity.Schema.__enum_map__())

  defp dump_field({:tour_period, enum}) when is_atom(enum),
    do:
      with(
        {:ok, value} <- Opportunity.TourPeriod.dump(enum),
        do: dump_field({:tour_period, value})
      )

  defp dump_field({:stage, enum}) when is_atom(enum),
    do: with({:ok, value} <- Opportunity.Stage.dump(enum), do: dump_field({:stage, value}))

  defp dump_field({key, value}),
    do: with({:ok, field} <- Opportunity.Schema.dump(key), do: {field, value})
end
