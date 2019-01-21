defmodule Re.Notifications.Mobile.Push do
  @moduledoc """
  Module for push notifications
  """
  require Logger

  def notify_user(user, listings) do
    user.device_id
    |> Pigeon.FCM.Notification.new()
    |> Pigeon.FCM.Notification.put_notification(%{
      "title" => "Relatório mensal",
      "body" => "Visualize seu relatório mensal de acesso aos seus imóveis"
    })
    |> Pigeon.FCM.Notification.put_data(%{"listings" => listings})
    |> Pigeon.FCM.push(&on_response/1)
  end

  defp on_response(%{status: :success} = n) do
    Pigeon.FCM.Notification.remove?(n)
    Pigeon.FCM.Notification.retry?(n)
  end

  defp on_response(%{status: :unauthorized}), do: Logger.warn("Push notification unauthorized")
  defp on_response(%{status: error} = n), do: Logger.warn("Push error: #{error}, payload: #{n}")
end
