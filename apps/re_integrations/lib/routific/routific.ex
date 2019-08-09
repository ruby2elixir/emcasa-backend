defmodule ReIntegrations.Routific do
  @moduledoc """
  Context module for routific.
  """

  alias ReIntegrations.{
    Routific.Client,
    Routific.Payload
  }

  @shift Application.get_env(:re_integrations, :routific_shift, {"8:00", "18:00"})
  @default_options Application.get_env(:re_integrations, :routific_options, [])

  def shift_start, do: elem(@shift, 0)
  def shift_end, do: elem(@shift, 1)

  def start_job(visits, schedule_opts \\ @default_options) do
    with {:ok, payload} <- Payload.Outbound.build(visits, schedule_opts),
         {:ok, %{body: body}} <- Client.start_job(payload),
         {:ok, %{"job_id" => job_id}} <- Jason.decode(body) do
      {:ok, job_id}
    end
  end

  def get_job_status(job_id) do
    with {:ok, %{body: body}} <- Client.fetch_job(job_id),
         {:ok, response} <- Jason.decode(body),
         {:ok, payload = %{status: :finished}} <- Payload.Inbound.build(response) do
      {:ok, payload}
    else
      {:ok, data = %{status_code: status_code}} when status_code != 200 ->
        {:error, data}

      {:ok, payload = %Payload.Inbound{status: status}} ->
        {status, payload}

      error ->
        error
    end
  end
end
