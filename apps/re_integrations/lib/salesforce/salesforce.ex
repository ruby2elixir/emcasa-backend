defmodule ReIntegrations.Salesforce do
  @moduledoc """
  Context module for routific.
  """

  alias ReIntegrations.{
    Repo,
    Routific,
    Salesforce.Client,
    Salesforce.Payload
  }

  @schedule_interval Application.get_env(:re_integrations, :tour_schedule_interval, days: 2)
  @tour_visit_duration Application.get_env(:re_integrations, :tour_visit_duration, 60)

  defp default_schedule_opts(),
    do: [date: Timex.now() |> Timex.shift(@schedule_interval)]

  def schedule_visits(schedule_opts \\ []) do
    opts = Keyword.merge(default_schedule_opts(), schedule_opts)

    with {:ok, %{status_code: 200, body: body}} <- fetch_visits(opts),
         {:ok, %{"records" => records}} = Jason.decode(body) do
      Enum.map(records, &build_visit/1)
      |> Routific.start_job()
    end
  end

  defp fetch_visits(opts) do
    date_constraint =
      opts
      |> Keyword.fetch!(:date)
      |> Timex.format!("%Y-%m-%d", :strftime)

    Client.query("""
    SELECT
      Id,
      OwnerId,
      AccountId,
      Dados_do_Imovel_para_Venda__c,
      Bairro__c,
      Data_Tour__c,
      Faixa_Hor_ria_Tour__c
    FROM Opportunity
    WHERE
      StageName = 'Agendamento' AND (
        Data_Tour__c = NULL OR
        DAY_ONLY(Data_Tour__c) = #{date_constraint})
    ORDER BY CreatedDate ASC
    """)
  end

  defp build_visit(record) do
    payload = record |> Payload.Opportunity.build()

    payload
    |> Map.take([:address])
    |> Map.merge(visit_period(payload))
    |> Map.put(:custom_notes, visit_notes(payload))
    |> Map.put(:duration, @tour_visit_duration)
  end

  defp visit_notes(visit),
    do: Map.take(visit, [:id, :owner_id, :account_id, :neighborhood])

  defp visit_period(%{tour_date: %DateTime{} = tour_date}),
    do: %{start: tour_date |> DateTime.to_time(), end: tour_date |> DateTime.to_time()}

  defp visit_period(%{tour_period: :morning}), do: %{start: ~T[09:00:00Z], end: ~T[12:00:00Z]}

  defp visit_period(%{tour_period: :afternoon}), do: %{start: ~T[12:00:00Z], end: ~T[18:00:00Z]}

  defp visit_period(_), do: %{start: ~T[09:00:00Z], end: ~T[18:00:00Z]}
end
