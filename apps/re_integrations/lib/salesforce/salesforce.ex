defmodule ReIntegrations.Salesforce do
  @moduledoc """
  Context module for salesforce
  """

  alias ReIntegrations.{
    Repo,
    Routific,
    Salesforce.Client,
    Salesforce.JobQueue,
    Salesforce.Mapper,
    Salesforce.Payload.Event,
    Salesforce.Payload.Opportunity
  }

  @routific_max_attempts Application.get_env(:re_integrations, :routific_max_attempts, 6)

  def insert_event(payload) do
    with {:ok, event} <- Event.validate(payload),
         {:ok, %{status_code: 200, body: body}} <- Client.insert_event(event),
         {:ok, data} <- Jason.decode(body) do
      {:ok, data}
    else
      {:ok, %{status_code: _status_code} = data} -> {:error, data}
      error -> error
    end
  end

  def update_opportunity(id, payload) do
    with {:ok, opportunity} <- Opportunity.validate(payload),
         {:ok, %{status_code: 200, body: body}} <- Client.update_opportunity(id, opportunity),
         {:ok, data} <- Jason.decode(body) do
      {:ok, data}
    else
      {:ok, %{status_code: _status_code} = data} -> {:error, data}
      error -> error
    end
  end

  def get_account(id), do: get_entity(id, :Account)

  def get_user(id), do: get_entity(id, :User)

  defp get_entity(id, type) do
    with {:ok, %{status_code: 200, body: body}} <- Client.get(id, type),
         {:ok, data} <- Jason.decode(body) do
      {:ok, data}
    else
      {:ok, %{status_code: _status_code} = data} -> {:error, data}
      error -> error
    end
  end

  def schedule_visits(schedule_opts) do
    with {:ok, %{status_code: 200, body: body}} <- fetch_visits(schedule_opts),
         {:ok, %{"records" => records}} = Jason.decode(body),
         {:ok, opportunities} <- Opportunity.build_all(records),
         {:ok, job_id} <-
           opportunities
           |> Enum.map(&Mapper.Routific.build_visit/1)
           |> Routific.start_job(schedule_opts) do
      %{"type" => "monitor_routific_job", "job_id" => job_id}
      |> JobQueue.new(max_attempts: @routific_max_attempts)
      |> Repo.insert()
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
      StageName = 'Confirmação Visita' AND
      Periodo_Disponibilidade_Tour__c != 'Proprietário com fotos' AND (
        Data_Fixa_para_o_Tour__c = NULL OR
        Data_Fixa_para_o_Tour__c = #{date_constraint})
    ORDER BY CreatedDate ASC
    """)
  end
end
