defmodule TaskerWeb.Presence do
  use Phoenix.Presence,
    otp_app: :tasker,
    pubsub_server: Tasker.PubSub
end
