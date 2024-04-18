import Config

config :tasker, dev_routes: true

config :tasker, Tasker.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "tasker_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :tasker, TaskerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "w1YkP2k27qOgUMTSLXmg2iOZsoEOJw4eLknDHsSWndjyldfdxCTMBfgRtJTAzdIZ",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:tasker, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:tasker, ~w(--watch)]}
  ]

config :tasker, TaskerWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/tasker_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :swoosh, :api_client, false

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
