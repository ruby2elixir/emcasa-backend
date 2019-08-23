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
    Salesforce.Payload.Opportunity,
    Salesforce.ZapierClient
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
    with opportunity <- struct(%Opportunity{}, payload),
         {:ok, %{status_code: 200, body: body}} <- Client.update_opportunity(id, opportunity),
         {:ok, data} <- Jason.decode(body) do
      {:ok, data}
    else
      {:ok, %{status_code: _status_code} = data} -> {:error, data}
      {:error, error} -> {:error, error}
      error -> {:error, error}
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
         {opportunities, invalid} <- build_opportunities(records) do
      Ecto.Multi.new()
      |> enqueue_failed_validations_report(invalid)
      |> enqueue_routific_job(opportunities, schedule_opts)
      |> Repo.transaction()
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

  def report_scheduled_tours(%Routific.Payload.Inbound{} = routific_response),
    do:
      with(
        {:ok, payload} <- Mapper.Zapier.build_report(routific_response),
        do: ZapierClient.post(payload)
      )

  defp enqueue_failed_validations_report(multi, errors),
    do: Enum.reduce(errors, multi, &update_failed_opportunity/2)

  defp update_failed_opportunity({:error, error, %{id: id}, %{errors: errors}}, multi) do
    JobQueue.enqueue(multi, "update_#{id}", %{
      "type" => "update_opportunity",
      "id" => id,
      "opportunity" => %{
        route_unserved_reason:
          errors
          |> Enum.map(fn {enum, {msg, _}} ->
            with({:ok, field} <- Opportunity.Schema.dump(enum), do: "#{field}: #{msg}")
          end)
          |> List.insert_at(0, "#{error}")
          |> Enum.join("\n")
      }
    })
  end

  defp enqueue_routific_job(multi, [], _schedule_opts), do: multi

  defp enqueue_routific_job(multi, entries, schedule_opts),
    do:
      with(
        {:ok, job_id} <-
          entries
          |> Enum.map(&Mapper.Routific.build_visit/1)
          |> Routific.start_job(schedule_opts),
        do:
          JobQueue.enqueue(
            multi,
            "monitor_routific_job",
            %{"type" => "monitor_routific_job", "job_id" => job_id},
            max_attempts: @routific_max_attempts
          )
      )

  defp build_opportunities(entries) do
    entries
    |> Enum.map(&with({:ok, value} <- Opportunity.build(&1), do: value))
    |> Enum.split_with(&is_ok/1)
  end

  defp is_ok({:error, _, _, _}), do: false
  defp is_ok(_), do: true
end
