defmodule Re.BuyerLeads.JobQueue do
  @moduledoc """
  Module for processing buyer leads to extract only necessary attributes
  Also attempts to associate user and listings
  """
  use EctoJob.JobQueue, table_name: "buyer_leads_jobs"

  require Logger

  alias Re.{
    BuyerLeads.Facebook,
    BuyerLeads.Grupozap,
    BuyerLeads.ImovelWeb,
    Repo
  }

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "grupozap_buyer_lead", "uuid" => uuid}) do
    Grupozap
    |> Repo.get(uuid)
    |> Grupozap.buyer_lead_changeset()
    |> insert_buyer_lead(multi)
    |> Repo.transaction()
  end

  def perform(%Multi{} = multi, %{"type" => "facebook_buyer", "uuid" => uuid}) do
    Facebook
    |> Repo.get(uuid)
    |> Facebook.buyer_lead_changeset()
    |> insert_buyer_lead(multi)
    |> Repo.transaction()
  end

  def perform(%Multi{} = multi, %{"type" => "imovelweb_buyer", "uuid" => uuid}) do
    ImovelWeb
    |> Repo.get(uuid)
    |> ImovelWeb.buyer_lead_changeset()
    |> insert_buyer_lead(multi)
    |> Repo.transaction()
  end

  def perform(_multi, job), do: raise("Job type not handled. Job: #{Kernel.inspect(job)}")

  defp insert_buyer_lead(changeset, multi), do: Multi.insert(multi, :insert_buyer_lead, changeset)
end
