defmodule ReIntegrations.Cloudinary.Client do
  @moduledoc """
  Client to handle images through cloudinary.
  """

  @client Application.get_env(:re_integrations, :cloudinary_client, Cloudex)

  require Logger

  def upload(image_list) do
    upload_response = @client.upload(image_list)

    {successful_uploads, failed_uploads} =
      Enum.split_with(upload_response, fn response -> success_response?(response) end)

    log_failed_uploads(failed_uploads)

    successful_uploads
  end

  defp success_response?({:ok, _response}), do: true
  defp success_response?(_), do: false

  defp log_failed_uploads([]), do: nil

  defp log_failed_uploads(errors) do
    errors
    |> Enum.map(fn {:error, error} -> error end)
    |> Enum.map(&Logger.error("Failed to upload images to cloudinary, reason: #{&1}"))
  end
end
