defmodule Re.AlikeTeller.Client do
  @moduledoc """
  Aliketeller service client
  """
  require Mockery.Macro

  @url Application.get_env(:re, :aliketeller_url, "")

  def get_payload do
    @url
    |> URI.parse()
    |> http_client().get()
  end

  defp http_client, do: Mockery.Macro.mockable(HTTPoison)
end
