defmodule ReIntegrations.Zapier do
  @moduledoc """
  Module for handling zapier webhook structure
  """
  require Logger

  alias Re.{
    Leads.FacebookBuyer,
    Repo
  }

  def new_buyer_lead(payload) do
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
end
