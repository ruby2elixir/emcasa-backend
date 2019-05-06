defmodule ReIntegrations.Grupozap do
  @moduledoc """
  Module for handling grupozap webhook structure
  """
  require Logger

  alias Re.{
    BuyerLeads.JobQueue,
    BuyerLeads.Grupozap,
    Repo
  }

  alias Ecto.{
    Changeset,
    Multi
  }

  def new_buyer_lead(payload) do
    %Grupozap{}
    |> Grupozap.changeset(payload)
    |> case do
      %{valid?: true} = changeset ->
        uuid = Changeset.get_field(changeset, :uuid)

        Multi.new()
        |> JobQueue.enqueue(:grupozap_job, %{"type" => "grupozap_buyer_lead", "uuid" => uuid})
        |> Multi.insert(:add_grupozap_buyer_lead, changeset)
        |> Repo.transaction()

      %{errors: errors} = changeset ->
        Logger.warn("Invalid payload from grupozap buyer. Errors: #{Kernel.inspect(changeset)}")

        {:error, :unexpected_payload, errors}
    end
  end
end
