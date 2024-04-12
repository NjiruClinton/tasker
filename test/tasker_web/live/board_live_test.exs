defmodule TaskerWeb.BoardLiveTest do
  use TaskerWeb.ConnCase, async: true

  alias Tasker.Accounts
  alias Tasker.Boards

  test "renders a board and creates cards inline", %{conn: conn} do
    owner = user_fixture()
    {:ok, board} = Boards.create_board(%{name: "Hiring demo"}, owner)
    [backlog | _] = board.lists

    {:ok, view, html} = live(conn, ~p"/boards/#{board.id}")

    assert html =~ "Hiring demo"
    assert html =~ "Backlog"

    view
    |> form("#new-card-#{backlog.id}",
      list_id: backlog.id,
      card: %{title: "Prepare LiveView walkthrough", priority: "high", labels: "liveview, elixir"}
    )
    |> render_submit()

    assert render(view) =~ "Prepare LiveView walkthrough"
    assert render(view) =~ "liveview"
  end

  defp user_fixture(attrs \\ %{}) do
    suffix = System.unique_integer([:positive])

    defaults = %{
      name: "Grace Hopper",
      email: "grace-#{suffix}@example.com",
      handle: "grace_#{suffix}"
    }

    {:ok, user} = Accounts.create_user(Map.merge(defaults, attrs))
    user
  end
end
