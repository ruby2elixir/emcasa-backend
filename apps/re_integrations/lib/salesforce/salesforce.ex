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
  @routific_max_attempts Application.get_env(:re_integrations, :routific_max_attempts, 6)
  @event_owner_id Application.get_env(:re_integrations, :salesforce_event_owner_id)

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

  def enqueue_insert_routific_events(
        multi,
        events,
        calendar_uuid,
        %Routific.Payload.Inbound{} = payload
      ) do
    Enum.reduce(events, multi, fn event, multi ->
      multi
      |> JobQueue.enqueue("schedule_#{event.id}", %{
        "type" => "insert_event",
        "event" => build_routific_event(event, calendar_uuid, payload)
      })
      |> JobQueue.enqueue("update_#{event.id}", %{
        "type" => "update_opportunity",
        "id" => event.id,
        "opportunity" => %{stage: :visit_scheduled}
      })
    end)
  end

  defp build_routific_event(event, calendar_uuid, payload) do
    with {:ok, date} <- payload.options |> Map.fetch!("date") |> Timex.parse("{ISO:Extended}"),
         {:ok, calendar} <- Re.Calendars.get(calendar_uuid),
         {:ok, sdr} <- get_user(event.custom_notes["owner_id"]),
         {:ok, account} <- get_account(event.custom_notes["account_id"]) do
      %{
        owner_id: @event_owner_id,
        what_id: event.id,
        type: :visit,
        address: event.address,
        start: update_datetime(event.start, date),
        end: update_datetime(event.end, date),
        duration: @tour_visit_duration,
        subject: "[#{calendar.name}] Visita para tour",
        description: build_event_description(event, %{sdr: sdr, account: account})
      }
    end
  end

  defp build_event_description(event, %{
         sdr: %{"Name" => sdr_name},
         account: %{"Name" => account_name, "PersonMobilePhone" => account_phone}
       }),
       do:
         "SDR: #{sdr_name}\n" <>
           "Cliente: #{account_name}\n" <>
           "Telefone: #{account_phone}\n" <>
           event.notes

  defp update_datetime(%Time{} = time, %DateTime{} = date), do: Timex.set(date, time: time)

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
         {:ok, job_id} <- start_routific_job(records, schedule_opts) do
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
      StageName = 'Confirmação Visita' AND (
        Data_Fixa_para_o_Tour__c = NULL OR
        Data_Fixa_para_o_Tour__c = #{date_constraint})
    ORDER BY CreatedDate ASC
    """)
  end

  defp start_routific_job(records, schedule_opts) do
    records
    |> Enum.map(&build_visit/1)
    |> Routific.start_job(schedule_opts)
  end

  defp build_visit(record) do
    with {:ok, opportunity} <- Opportunity.build(record) do
      opportunity
      |> Map.take([:id, :address, :neighborhood, :notes])
      |> Map.merge(Opportunity.visit_start_window(opportunity))
      |> Map.put(:custom_notes, visit_notes(opportunity))
      |> Map.put(:duration, @tour_visit_duration)
    end
  end

  defp visit_notes(opportunity),
    do: Map.take(opportunity, [:owner_id, :account_id])
end
