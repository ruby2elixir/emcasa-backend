defmodule ReIntegrations.PriceTeller do
  @moduledoc """
  Context module for price suggestion
  """
  use Retry

  require Logger

  alias __MODULE__.{
    Input,
    Output,
    Client
  }

  @retry_expiry Application.get_env(:re_integrations, :retry_expiry, 30_000)

  def ask(params) do
    with {:ok, params} <- Input.validate(params),
         {:ok, %{body: body}} <- do_post(params),
         {:ok, payload} <- Poison.decode(body),
         {:ok, response} <- Output.validate(payload) do
      {:ok, response}
    else
      {:error, error, params, changeset} ->
        Logger.warn("#{Kernel.inspect(error)} in priceteller. Payload: #{Kernel.inspect(params)}")

        {:error, changeset}

      {:error, :invalid_output, payload} ->
        Logger.warn("Invalid output from priceteller. Payload: #{Kernel.inspect(payload)}")

        {:error, :bad_request}

      error ->
        Logger.warn("Something went wrong. Error: #{Kernel.inspect(error)}")

        error
    end
  end

  defp do_post(params) do
    retry with: exp_backoff() |> randomize() |> expiry(@retry_expiry),
          rescue_only: [TimeoutError] do
      Client.post(params)
    after
      {:ok, response} -> {:ok, response}
    else
      error -> error
    end
  end
end
