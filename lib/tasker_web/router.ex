defmodule TaskerWeb.Router do
  use TaskerWeb, :router

  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TaskerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TaskerWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/boards", BoardLive.Index, :index
    live "/boards/new", BoardLive.Index, :new
    live "/boards/:id", BoardLive.Show, :show
  end

  if Application.compile_env(:tasker, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TaskerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
