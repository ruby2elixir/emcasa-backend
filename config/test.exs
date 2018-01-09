use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :re, ReWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :re, ReWeb.Guardian,
  allowed_algos: ["ES512"],
  secret_key: %{
    "alg" => "ES512",
    "crv" => "P-521",
    "d" => "W9YqJjm9e452o7dPksq6vBZepwd8a4jZFW_t-UIDMUF06kd1dLsxpKXpk8APuK-d5J-50HF4BdAGjmJpPkpOQ1U",
    "kty" => "EC",
    "use" => "sig",
    "x" => "AaGpyKIkI5oDXfdBuGEEIUnARSlUFiYx0fwwXqgQy4qyNthel0Rk8bFTwR4_R7yr7FN5lu9DY2G3Yyhr13b9F2e4",
    "y" => "ABHa0GzAhxsmJkS5JvFMk3MHIoG4jw1MNigpzU6LyBWO9zWFQ636J9H0mOISk835dkqws_MKOND4EeRhlbIHZRP7"
  }

# Configure your database
config :re, Re.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "re_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :re, Re.Mailer,
  adapter: Swoosh.Adapters.Test
