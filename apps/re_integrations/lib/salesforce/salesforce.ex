defmodule ReIntegrations.Salesforce do
  @moduledoc """
  Context module for routific.
  """

  alias ReIntegrations.{
    Repo,
    Salesforce.Client
  }

  @schedule_interval Application.get_env(:re_integrations, :salesforce_schedule_interval, days: 2)

  defp default_schedule_opts(),
    do: [date: Timex.now() |> Timex.shift(@schedule_interval)]

  def fetch_visits(schedule_opts \\ []) do
    opts = Keyword.merge(default_schedule_opts(), schedule_opts)

    with {:ok, %{status_code: 200, body: body}} <- query_visits(opts),
         {:ok, payload} <- Jason.decode(body) do
    end
  end

  defp query_visits(opts) do
    date_constraint =
      opts
      |> Keyword.fetch!(:date)
      |> Timex.format!("%Y-%m-%d", :strftime)

    Client.query("""
    SELECT
      Id,
      OwnerId,
      AccountId,
      Dados_do_Imovel_para_Venda__c,
      Bairro__c,
      Data_Tour__c,
      Faixa_Hor_ria_Tour__c
    FROM Opportunity
    WHERE
      StageName = 'Agendamento' AND (
        Data_Tour__c = NULL OR
        DAY_ONLY(Data_Tour__c) = #{date_constraint})
    ORDER BY CreatedDate ASC
    """)
  end
end
