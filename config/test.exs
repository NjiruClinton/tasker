import Config

config :tasker, Tasker.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "tasker_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :tasker, TaskerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "8dn+UgJ+NrLD3VOGRXpJuEUiLJfzv/npkGTQuSxChBG7aBGg+0hBffvWYXLFFk3Z",
  server: false

config :tasker, Tasker.Mailer, adapter: Swoosh.Adapters.Test

config :swoosh, :api_client, false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime
