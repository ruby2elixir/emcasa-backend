defmodule Re.SellerLeads.JobQueue do
  @moduledoc """
  Module for processing seller leads to extract only necessary attributes
  """
  use EctoJob.JobQueue, table_name: "seller_lead_jobs"

  require Ecto.Query

  alias Re.{
    PriceSuggestions.Request,
    Repo,
    SellerLeads,
    SellerLeads.Salesforce.Client,
    User,
    SellerLeads.Broker
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

  def perform(%Multi{} = multi, %{"type" => "process_broker_seller_lead", "uuid" => uuid}) do
    broker_lead =
      Broker
      |> Ecto.Query.preload([:address, :broker])
      |> Repo.get_by(uuid: uuid)
      |> check_broker_user()

    property_owner = Repo.get_by(User, phone: broker_lead.owner_telephone)

    broker_lead
    |> Broker.seller_lead_changeset(property_owner)
  end

  def perform(%Multi{} = multi, %{"type" => "create_lead_salesforce", "uuid" => uuid}) do
    {:ok, seller_lead} = SellerLeads.get_preloaded(uuid, [:address, :user])

    multi
    |> Multi.run(:create_salesforce_lead, fn _repo, _changes ->
      Client.create_lead(seller_lead)
    end)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(_multi, job), do: raise("Job type not handled. Job: #{Kernel.inspect(job)}")

  defp check_broker_user(%{uuid: uuid, broker: %{uuid: broker_uuid, salesforce_id: nil}}),
       do: raise("User:[uuid:#{broker_uuid}] doesn't have a salesforce_id - Failing integration for BrokerLead:[uuid:#{uuid}]")

  defp check_broker_user(broker_lead), do: broker_lead

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
