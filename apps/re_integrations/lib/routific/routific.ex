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
    with {:ok, %{body: body}} <- Client.start_job(visits),
         {:ok, %{"job_id" => job_id}} <-
           Jason.decode(body) do
      %{"type" => "monitor_routific_job", "job_id" => job_id}
      |> JobQueue.new()
      |> Repo.insert()
    else
      {_, error} -> {:error, error}
    end
  end

  def get_job_status(job_id) do
    with {:ok, %{body: body}} <- Client.fetch_job(job_id),
         {:ok, %{"status" => "finished", "output" => output}} <-
           Jason.decode(body) do
      {:ok, output}
    else
      {_, %{status_code: status_code}} -> {:error, %{"status_code" => status_code}}
      {:ok, %{"status" => status}} -> {:error, %{"status" => status}}
    end
  end
end
