defmodule ReIntegrations.Salesforce do
  @moduledoc """
  Context module for salesforce
  """

  alias ReIntegrations.{
    Repo,
    Routific,
    Salesforce.Client,
    Salesforce.JobQueue,
    Salesforce.Payload.Event,
    Salesforce.Payload.Opportunity
  }

  @tour_visit_duration Application.get_env(:re_integrations, :tour_visit_duration, 60)

  def enqueue_insert_event(payload) do
    %{"type" => "insert_event", "event" => payload}
    |> JobQueue.new()
    |> Repo.insert()
  end

  def insert_event(payload) do
    with {:ok, event} <- Event.validate(payload),
         {:ok, %{status_code: 200, body: body}} <- Client.insert(event),
         {:ok, data} <- Jason.decode(body) do
      {:ok, data}
    else
      {:ok, %{status_code: _status_code} = data} -> {:error, data}
      error -> error
    end
  end

  def schedule_visits(schedule_opts \\ []) do
    with {:ok, %{status_code: 200, body: body}} <- fetch_visits(schedule_opts),
         {:ok, %{"records" => records}} = Jason.decode(body) do
      records
      |> Enum.map(&build_visit/1)
      |> Routific.start_job()
    end
  end

  defp fetch_visits(opts) do
    date_constraint =
      opts
      |> Keyword.fetch!(:date)
      |> Timex.format!("%Y-%m-%d", :strftime)

    fields =
      Opportunity.Schema.__enum_map__()
      |> Keyword.values()
      |> Enum.join(", ")

    Client.query("""
    SELECT #{fields}
    FROM Opportunity
    WHERE
      StageName = 'Confirmação Visita' AND (
        Data_Fixa_para_o_Tour__c = NULL OR
        Data_Fixa_para_o_Tour__c = #{date_constraint})
    ORDER BY CreatedDate ASC
    """)
  end

  defp build_visit(record) do
    with {:ok, opportunity} <- Opportunity.build(record) do
      opportunity
      |> Map.take([:id, :address, :neighborhood])
      |> Map.merge(Opportunity.visit_start_window(opportunity))
      |> Map.put(:custom_notes, visit_notes(opportunity))
      |> Map.put(:duration, @tour_visit_duration)
    end
  end

  defp visit_notes(opportunity),
    do: Map.take(opportunity, [:owner_id, :account_id, :neighborhood])
end
