defmodule ReIntegrations.Zapier do
  @moduledoc """
  Module for handling zapier webhook structure
  """
  require Logger

  alias Re.{
    Leads.Buyer.JobQueue,
    Leads.FacebookBuyer,
    Leads.ImovelWebBuyer,
    Repo
  }

  alias Ecto.{
    Changeset,
    Multi
  }

  def new_buyer_lead(%{"source" => "facebook_buyer"} = payload) do
    %FacebookBuyer{}
    |> FacebookBuyer.changeset(payload)
    |> do_new_buyer_lead("facebook_buyer")
  end

  def new_buyer_lead(%{"source" => "imovelweb_buyer"} = payload) do
    %ImovelWebBuyer{}
    |> ImovelWebBuyer.changeset(payload)
    |> do_new_buyer_lead("imovelweb_buyer")
  end

  def new_buyer_lead(%{"source" => _source} = payload) do
    Logger.warn("Invalid payload source. Payload: #{Kernel.inspect(payload)}")

    {:error, :unexpected_payload, payload}
  end

  def new_buyer_lead(payload) do
    Logger.warn("No payload source. Payload: #{Kernel.inspect(payload)}")

    {:error, :unexpected_payload, payload}
  end

  defp do_new_buyer_lead(changeset, type) do
    case changeset do
      %{valid?: true} = changeset ->
        uuid = Changeset.get_field(changeset, :uuid)

        Multi.new()
        |> JobQueue.enqueue(:buyer_lead_job, %{"type" => type, "uuid" => uuid})
        |> Multi.insert(:add_buyer_lead, changeset)
        |> Repo.transaction()

      %{errors: errors} ->
        Logger.warn(
          "Invalid payload from zapier's imovelweb buyer. Errors: #{Kernel.inspect(errors)}"
        )

        {:error, :unexpected_payload, errors}
    end
  end
end
