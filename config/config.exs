import Config

config :tasker,
  ecto_repos: [Tasker.Repo]

config :tasker, TaskerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: TaskerWeb.ErrorHTML, json: TaskerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Tasker.PubSub,
  live_view: [signing_salt: "tasker-live"]

config :tasker, Tasker.Mailer, adapter: Swoosh.Adapters.Local

config :esbuild,
  version: "0.17.11",
  tasker: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.4.3",
  tasker: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
