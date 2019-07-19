defmodule ReIntegrations.Routific do
  @moduledoc """
  Context module for routific.
  """

  alias ReIntegrations.{
    Repo,
    Routific.Client,
    Routific.JobQueue,
    Routific.Payload
  }

  @shift Application.get_env(:re_integrations, :routific_shift, {~T[08:00:00Z], ~T[18:00:00Z]})
  @max_attempts Application.get_env(:re_integrations, :routific_max_attempts, 6)

  def shift_start, do: elem(@shift, 0)
  def shift_end, do: elem(@shift, 1)

  def start_job(visits) do
    with {:ok, %{body: body}} <- visits |> Payload.Outbound.build() |> Client.start_job(),
         {:ok, %{"job_id" => job_id}} <- Jason.decode(body) do
      %{"type" => "monitor_routific_job", "job_id" => job_id}
      |> JobQueue.new(max_attempts: @max_attempts)
      |> Repo.insert()
    end
  end

  def get_job_status(job_id) do
    with {:ok, %{body: body}} <- Client.fetch_job(job_id),
         {:ok, payload = %{"status" => "finished"}} <- Jason.decode(body) do
      {:ok, Payload.Inbound.build(payload)}
    else
      {:ok, data = %{status_code: status_code}} when status_code != 200 ->
        {:error, data}

      {:ok, payload = %{"status" => status}} ->
        {String.to_atom(status), Payload.Inbound.build(payload)}

      {:error, data} ->
        {:error, data}
    end
  end
end
