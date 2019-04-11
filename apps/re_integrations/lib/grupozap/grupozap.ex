defmodule ReIntegrations.Grupozap do
  @moduledoc """
  Module for handling grupozap webhook structure
  """
  require Logger

  alias Re.{
    Leads.GrupozapBuyer,
    Repo
  }

  def new_buyer_lead(payload) do
    %GrupozapBuyer{}
    |> GrupozapBuyer.changeset(payload)
    |> case do
      %{valid?: true} = changeset ->
        Repo.insert(changeset)

      %{errors: errors} = changeset ->
        Logger.warn("Invalid payload from grupozap buyer. Errors: #{Kernel.inspect(changeset)}")

        {:error, :unexpected_payload, errors}
    end
  end
end
