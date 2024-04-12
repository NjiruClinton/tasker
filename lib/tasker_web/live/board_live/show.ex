defmodule TaskerWeb.BoardLive.Show do
  use TaskerWeb, :live_view

  alias Tasker.Accounts
  alias Tasker.Boards

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    current_user = Accounts.ensure_demo_user()
    board = Boards.get_board!(id)

    if connected?(socket) do
      Boards.subscribe(board.id)
      Phoenix.PubSub.subscribe(Tasker.PubSub, presence_topic(board.id))

      TaskerWeb.Presence.track(self(), presence_topic(board.id), "user:#{current_user.id}", %{
        name: current_user.name,
        handle: current_user.handle,
        joined_at: System.system_time(:second)
      })
    end

    socket =
      socket
      |> assign(:page_title, board.name)
      |> assign(:board, board)
      |> assign(:current_user, current_user)
      |> assign(:collaborators, collaborators(board.id))
      |> assign(:list_form, to_form(%{"name" => ""}, as: :list))
      |> assign(:card_form, to_form(%{"title" => "", "priority" => "medium", "labels" => ""}, as: :card))

    {:ok, socket}
  end

  @impl true
  def handle_info({Boards, _event, _payload}, socket) do
    {:noreply, refresh_board(socket)}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff"}, socket) do
    {:noreply, assign(socket, :collaborators, collaborators(socket.assigns.board.id))}
  end

  @impl true
  def handle_event("create-list", %{"list" => list_params}, socket) do
    case Boards.create_list(socket.assigns.board, list_params, socket.assigns.current_user) do
      {:ok, _list} ->
        {:noreply,
         socket
         |> refresh_board()
         |> assign(:list_form, to_form(%{"name" => ""}, as: :list))}

      {:error, changeset} ->
        {:noreply, assign(socket, :list_form, to_form(changeset, as: :list))}
    end
  end

  def handle_event("create-card", %{"list_id" => list_id, "card" => card_params}, socket) do
    list = Enum.find(socket.assigns.board.lists, &(to_string(&1.id) == to_string(list_id)))

    case Boards.create_card(socket.assigns.board, list, card_params, socket.assigns.current_user) do
      {:ok, _card} ->
        {:noreply,
         socket
         |> refresh_board()
         |> assign(:card_form, to_form(%{"title" => "", "priority" => "medium", "labels" => ""}, as: :card))}

      {:error, changeset} ->
        {:noreply, assign(socket, :card_form, to_form(changeset, as: :card))}
    end
  end

  def handle_event("move-card", %{"card_id" => card_id, "list_id" => list_id, "position" => position}, socket) do
    {:ok, _card} = Boards.move_card(card_id, list_id, position, socket.assigns.current_user)
    {:noreply, refresh_board(socket)}
  end

  def handle_event("mark-done", %{"id" => card_id}, socket) do
    card = Boards.get_card!(card_id)
    {:ok, _card} = Boards.update_card(card, %{"status" => "done"}, socket.assigns.current_user)
    {:noreply, refresh_board(socket)}
  end

  defp refresh_board(socket) do
    assign(socket, :board, Boards.get_board!(socket.assigns.board.id))
  end

  defp collaborators(board_id) do
    board_id
    |> presence_topic()
    |> TaskerWeb.Presence.list()
    |> Enum.map(fn {_key, %{metas: [meta | _]}} -> meta end)
    |> Enum.sort_by(& &1.name)
  end

  defp presence_topic(board_id), do: "boards:#{board_id}:presence"
end
