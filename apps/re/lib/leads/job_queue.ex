defmodule Re.Leads.Buyer.JobQueue do
  use EctoJob.JobQueue, table_name: "buyer_leads_jobs"

  require Logger

  alias Re.{
    Leads.GrupozapBuyer,
    Leads.Buyer,
    Listing,
    Repo,
    User
  }

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "grupozap_buyer_lead", "uuid" => uuid} = job) do
    GrupozapBuyer
    |> Repo.get(uuid)
    |> buyer_lead_changeset()
    |> persist(multi)
  end

  def perform(multi, job) do
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
    case Repo.get_by(User, phone: phone_number) do
      nil -> nil
      user -> user.uuid
    end
  end

  defp extract_listing_uuid(id) do
    case Repo.get(Listing, id) do
      nil -> nil
      listing -> listing.uuid
    end
  end
end
