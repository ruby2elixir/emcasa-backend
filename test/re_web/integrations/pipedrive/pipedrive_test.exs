defmodule ReWeb.Integrations.PipedriveTest do
  use Re.ModelCase

  doctest ReWeb.Integrations.Pipedrive

  alias ReWeb.Integrations.Pipedrive

  describe "handle_webhook/1" do
    test "update.activity: previous not done, current done" do
      assert Pipedrive.validate_payload(%{
               "event" => "updated.activity",
               "current" => %{"type" => "visita_ao_imvel", "done" => true},
               "previous" => %{"done" => false}
             }) == :ok
    end
  end
end
