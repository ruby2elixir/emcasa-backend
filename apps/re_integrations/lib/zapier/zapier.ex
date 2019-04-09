defmodule ReIntegrations.Zapier do
  @moduledoc """
  Module for handling zapier webhook structure
  """
  require Logger

  alias Re.{
    Leads.FacebookBuyer,
    Repo
  }

  def validate_payload(%{
        "full_name" => _,
        "timestamp" => _,
        "lead_id" => _,
        "email" => _,
        "phone_number" => _,
        "neighborhoods" => _,
        "location" => location
      })
      when location in ~w(SP RJ),
      do: :ok

  def validate_payload(payload) do
    Logger.info("Bad payload: #{Kernel.inspect(payload)}")

    {:error, :unexpected_payload}
  end

  def new_buyer_lead(payload) do
    %FacebookBuyer{}
    |> FacebookBuyer.changeset(payload)
    |> Repo.insert()
  end
end
