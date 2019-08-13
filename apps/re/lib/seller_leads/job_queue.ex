defmodule Re.SellerLeads.JobQueue do
  @moduledoc """
  Module for processing seller leads to extract only necessary attributes
  """
  use EctoJob.JobQueue, table_name: "seller_lead_jobs"

  require Ecto.Query

  alias Re.{
    PriceSuggestions.Request,
    Repo,
    SellerLead,
    SellerLeads,
    SellerLeads.Salesforce,
    User
  }

  alias Ecto.{
    Changeset,
    Multi
  }

  def perform(%Multi{} = multi, %{"type" => "process_price_suggestion_request", "uuid" => uuid}) do
    request =
      Request
      |> Ecto.Query.preload([:address, :user])
      |> Repo.get_by(uuid: uuid)

    request
    |> Request.seller_lead_changeset()
    |> insert_seller_lead(multi)
    |> update_name(request)
    |> update_email(request)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(%Multi{} = multi, %{"type" => "create_lead_salesforce", "uuid" => uuid}) do
    {:ok, seller_lead} = SellerLeads.get_preloaded(uuid, [:address, :user])

    multi
    |> Multi.run(:create_salesforce_lead, fn _repo, _changes ->
      Salesforce.create_lead(seller_lead)
    end)
    |> Multi.run(:update_seller_lead, fn _repo, %{create_salesforce_lead: %{"id" => id}} ->
      seller_lead
      |> SellerLead.changeset(%{salesforce_id: id})
      |> Repo.update()
    end)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(_multi, job), do: raise("Job type not handled. Job: #{Kernel.inspect(job)}")

  defp insert_seller_lead(changeset, multi) do
    uuid = Changeset.get_field(changeset, :uuid)

    multi
    |> Multi.insert(:insert_seller_lead, changeset)
    |> __MODULE__.enqueue(:salesforce_job, %{"type" => "create_lead_salesforce", "uuid" => uuid})
  end

  defp update_name(multi, %{name: name, user: %{name: nil} = user}),
    do: Multi.update(multi, :update_user_name, User.update_changeset(user, %{name: name}))

  defp update_name(multi, _), do: multi

  defp update_email(multi, %{email: email, user: %{email: nil} = user}),
    do: Multi.update(multi, :update_user_email, User.update_changeset(user, %{email: email}))

  defp update_email(multi, _), do: multi

  defp handle_error({:ok, result}), do: {:ok, result}

  defp handle_error(_error), do: raise("Error when performing SellerLeads.JobQueue")
end
