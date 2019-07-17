defmodule ReIntegrations.Routific do
  @moduledoc """
  Context module to use importers.
  """

  alias ReIntegrations.{
    Routific.Client,
    Routific.JobQueue,
    Repo
  }

  @shift Application.get_env(:re_integrations, :routific_shift, {"8:00", "16:00"})

  def shift_start, do: elem(@shift, 0)
  def shift_end, do: elem(@shift, 1)

  def start_job(visits) do
    with {:ok, %{"job_id" => job_id}} <- Client.start_job(visits) do
      %{"type" => "monitor_routific_job", "job_id" => job_id}
      |> JobQueue.new()
      |> Repo.insert()
    end
  end

  def get_job_status(job_id) do
    with {:ok, payload = %{status: "finished"}} <- Client.fetch_job(job_id) do
      {:ok, payload}
    else
      {_, %{status_code: status_code}} -> {:error, %{status_code: status_code}}
      {_, %{status: status}} -> {:error, %{status: status}}
    end
  end
end
