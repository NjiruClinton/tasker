defmodule TaskerWeb.PageController do
  use TaskerWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/boards")
  end
end
