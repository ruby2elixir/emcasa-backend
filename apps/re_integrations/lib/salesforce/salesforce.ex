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
    with {:ok, opportunity} <- Payload.Opportunity.build(record) do
      opportunity
      |> Map.take([:id, :address, :neighborhood])
      |> Map.merge(Payload.Opportunity.visitation_period(opportunity))
      |> Map.put(:custom_notes, visit_notes(opportunity))
      |> Map.put(:duration, @tour_visit_duration)
    end
  end

  defp visit_notes(opportunity),
    do: Map.take(opportunity, [:owner_id, :account_id, :neighborhood])
end
