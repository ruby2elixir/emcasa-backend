defmodule ReIntegrations.RoutificTest do
  use ReIntegrations.ModelCase

  import Re.CustomAssertion

  alias ReIntegrations.{
    Routific,
    Routific.JobQueue,
    Repo
  }

  @visits [
    %{
      "id" => "1",
      "duration" => 10,
      "address" => "x",
      "neighborhood" => "Vila Mariana",
      "lat" => 1.0,
      "lng" => 1.0
    }
  ]

  describe "start_job/1" do
    test "create a new job to monitor routific request" do
      assert {:ok, _} = Routific.start_job(@visits)
      assert_enqueued_job(Repo.all(JobQueue), "monitor_routific_job")
    end
  end

  describe "get_job_status/1" do
    test "fetch routific job status" do
      assert {:error, %{status_code: 404}} = Routific.get_job_status("INVALID_JOB_ID")

      assert {:error, %{status: "pending"}} = Routific.get_job_status("PENDING_JOB_ID")

      assert {:error, %{status: "error"}} = Routific.get_job_status("FAILED_JOB_ID")

      assert {:ok, %Routific.Payload.Inbound{status: "finished"}} =
               Routific.get_job_status("FINISHED_JOB_ID")
    end
  end
end
