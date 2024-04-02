defmodule TaskerWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint TaskerWeb.Endpoint

      use TaskerWeb, :verified_routes

      import Plug.Conn
      import Phoenix.ConnTest
      import Phoenix.LiveViewTest
      import TaskerWeb.ConnCase
    end
  end

  setup tags do
    Tasker.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
