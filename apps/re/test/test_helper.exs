ExUnit.configure formatters: [JUnitFormatter, ExUnit.CLIFormatter]

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Re.Repo, :manual)

Faker.start()

case File.ls("temp") do
  {:error, :enoent} -> File.mkdir("temp")
  _ -> :ok
end
