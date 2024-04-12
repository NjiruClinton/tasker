defmodule TaskerWeb.BoardLive.Index do
  use TaskerWeb, :live_view

  alias Tasker.Accounts
  alias Tasker.Boards
  alias Tasker.Boards.Board

  @impl true
  def mount(_params, _session, socket) do
    current_user = Accounts.ensure_demo_user()

    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:boards, Boards.list_boards())
      |> assign(:form, to_form(Boards.change_board(%Board{})))

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket =
      case socket.assigns.live_action do
        :new ->
          socket
          |> assign(:page_title, "New Board")
          |> assign(:form, to_form(Boards.change_board(%Board{})))

        :index ->
          socket
          |> assign(:page_title, "Boards")
          |> assign(:boards, Boards.list_boards())
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"board" => board_params}, socket) do
    changeset =
      %Board{}
      |> Boards.change_board(board_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"board" => board_params}, socket) do
    case Boards.create_board(board_params, socket.assigns.current_user) do
      {:ok, board} ->
        {:noreply,
         socket
         |> put_flash(:info, "Board created")
         |> push_navigate(to: ~p"/boards/#{board.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
