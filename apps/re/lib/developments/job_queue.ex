defmodule Re.Developments.JobQueue do
  @moduledoc """
  Module for processing buyer leads to extract only necessary attributes
  Also attempts to associate user and listings
  """
  use EctoJob.JobQueue, table_name: "units_jobs"

  require Ecto.Query
  require Logger

  alias Re.{
    Repo
  }

  alias Ecto.{
    Multi,
    Query
  }

  def perform(%Multi{} = multi, %{"type" => "new_unit", "uuid" => uuid}) do
    :ok
  end
end
