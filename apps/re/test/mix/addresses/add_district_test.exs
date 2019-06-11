defmodule Mix.Tasks.Re.Addresses.AddDistrictTest do
  use Re.ModelCase

  setup do
    Mix.shell(Mix.Shell.Process)

    on_exit(fn ->
      Mix.shell(Mix.Shell.IO)
    end)

    :ok
  end

  describe "run/1" do
    test "inserts district" do
      Mix.Tasks.Re.Addresses.AddDistrict.run([])

      assert_received {:mix_shell, :info, [message]}

      assert message =~ "Inserted district:"
      assert Re.Repo.get_by(Re.Addresses.District, name_slug: "vila-mariana")
    end
  end
end
