defmodule ReIntegrations.Zapier do
  @moduledoc """
  Module for handling zapier webhook structure
  """
  require Logger

  alias Re.{
    BuyerLeads,
    BuyerLeads.JobQueue,
    BuyerLeads.ImovelWeb,
    SellerLeads,
    Repo
  }

  alias Ecto.{
    Changeset,
    Multi
  }

  def new_lead(%{"source" => "facebook_buyer"} = payload) do
    %BuyerLeads.Facebook{}
    |> BuyerLeads.Facebook.changeset(payload)
    |> do_new_buyer_lead("facebook_buyer")
  end

  def new_lead(%{"source" => "imovelweb_buyer"} = payload) do
    %ImovelWeb{}
    |> ImovelWeb.changeset(payload)
    |> do_new_buyer_lead("imovelweb_buyer")
  end

  def new_lead(%{"source" => "facebook_seller"} = payload) do
    %SellerLeads.Facebook{}
    |> SellerLeads.Facebook.changeset(payload)
    |> Repo.insert()
  end

  def new_lead(%{"source" => _source} = payload) do
    Logger.warn("Invalid payload source. Payload: #{Kernel.inspect(payload)}")

    {:error, :unexpected_payload, payload}
  end

  def new_lead(payload) do
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
        Logger.warn("Invalid payload from #{type}. Errors: #{Kernel.inspect(errors)}")

        {:error, :unexpected_payload, errors}
    end
  end
end
