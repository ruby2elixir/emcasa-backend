defmodule ReIntegrations.Salesforce.Mapper.Routific do
  @moduledoc """
  Module for mapping routific inputs to salesforce entities.
  """
  alias ReIntegrations.{
    Routific,
    Salesforce,
    Salesforce.Payload.Opportunity
  }

  @tour_visit_duration Application.get_env(:re_integrations, :tour_visit_duration, 40)
  @event_owner_id Application.get_env(:re_integrations, :salesforce_event_owner_id)

  def build_visit(%Opportunity{} = opportunity) do
    opportunity
    |> Map.take([:id, :address, :neighborhood, :notes])
    |> Map.merge(Opportunity.visit_start_window(opportunity))
    |> Map.put(:custom_notes, visit_notes(opportunity))
    |> Map.put(:duration, @tour_visit_duration)
  end

  defp visit_notes(opportunity),
    do: Map.take(opportunity, [:owner_id, :account_id])

  def build_event(event, calendar_uuid, %Routific.Payload.Inbound{} = payload) do
    with {:ok, date} <- payload.options |> Map.fetch!("date") |> Timex.parse("{ISO:Extended}"),
         {:ok, calendar} <- Re.Calendars.get(calendar_uuid),
         {:ok, sdr} <- Salesforce.get_user(event.custom_notes["owner_id"]),
         {:ok, account} <- Salesforce.get_account(event.custom_notes["account_id"]) do
      start_time = event.start |> update_datetime(date) |> Timex.shift(minutes: event.idle_time)
      end_time = update_datetime(event.end, date)
      duration = Timex.diff(end_time, start_time, :minutes)

      %{
        owner_id: @event_owner_id,
        what_id: event.id,
        type: :visit,
        address: event.address,
        start: start_time,
        end: end_time,
        duration: duration,
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
           if(is_nil(event.notes), do: "", else: event.notes)

  defp update_datetime(%Time{} = time, %DateTime{} = date),
    do: date |> Timex.set(time: time) |> Timex.Timezone.convert(:utc)
end
