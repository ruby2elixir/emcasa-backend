defmodule ReIntegrations.Zapier do
  @moduledoc """
  Module for handling zapier webhook structure
  """
  require Logger

  alias Re.{
    Leads.FacebookBuyer,
    Repo
  }

  def new_buyer_lead(%{"source" => "facebook_buyer"} = payload) do
    %FacebookBuyer{}
    |> FacebookBuyer.changeset(payload)
    |> case do
      %{valid?: true} = changeset ->
        Repo.insert(changeset)

      %{errors: errors} ->
        Logger.warn(
          "Invalid payload from zapier's facebook buyer. Errors: #{Kernel.inspect(errors)}"
        )

        {:error, :unexpected_payload, errors}
    end
  end

  def new_buyer_lead(%{"source" => _source} = payload) do
    Logger.warn("Invalid payload source. Payload: #{Kernel.inspect(payload)}")

    {:error, :unexpected_payload, payload}
  end

  def new_buyer_lead(payload) do
    Logger.warn("No payload source. Payload: #{Kernel.inspect(payload)}")

    {:error, :unexpected_payload, payload}
  end
end
