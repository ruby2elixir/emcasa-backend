defmodule ReIntegrations.PriceTeller do
  @moduledoc """
  Context module for price suggestion
  """
  require Logger

  alias __MODULE__.{
    Input,
    Output,
    Client
  }

  def ask(params) do
    with {:ok, params} <- Input.validate(params),
         {:ok, %{body: body}} <- Client.post(params),
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
end
