defmodule Re.Leads.Buyer.JobQueue do
  @moduledoc """
  Module for processing buyer leads to extract only necessary attributes
  Also attempts to associate user and listings
  """
  use EctoJob.JobQueue, table_name: "buyer_leads_jobs"

  require Logger

  alias Re.{
    Accounts.Users,
    Leads.Buyer,
    Leads.GrupozapBuyer,
    Listings,
    Repo
  }

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "grupozap_buyer_lead", "uuid" => uuid}) do
    GrupozapBuyer
    |> Repo.get(uuid)
    |> buyer_lead_changeset()
    |> persist(multi)
  end

  def perform(_multi, job) do
    Logger.warn("Job format not handled. Job: #{Kernel.inspect(job)}")

    raise "Job not handled"
  end

  defp buyer_lead_changeset(nil), do: raise("Leads.GrupozapBuyer not found")

  defp buyer_lead_changeset(gzb) do
    phone_number = "+55" <> gzb.ddd <> gzb.phone

    Buyer.changeset(%Buyer{}, %{
      name: gzb.name,
      email: gzb.email,
      phone_number: phone_number,
      origin: gzb.lead_origin,
      user_uuid: extract_user_uuid(phone_number),
      listing_uuid: extract_listing_uuid(gzb.client_listing_id)
    })
  end

  defp persist(changeset, multi), do: Multi.insert(multi, :insert_buyer_lead, changeset)

  defp extract_user_uuid(phone_number) do
    case Users.get_by_phone(phone_number) do
      {:ok, user} -> user.uuid
      _error -> nil
    end
  end

  defp extract_listing_uuid(id) do
    case Listings.get(id) do
      {:ok, listing} -> listing.uuid
      _error -> nil
    end
  end
end
