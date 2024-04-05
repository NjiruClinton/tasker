defmodule Tasker.Boards do
  @moduledoc """
  Board, list, card, membership, and activity workflows.

  Most UI operations end here so LiveViews stay focused on presentation while the
  context owns ordering, validations, transactions, and real-time broadcasts.
  """

  import Ecto.Query

  alias Ecto.Multi
  alias Tasker.Accounts.User
  alias Tasker.Boards.{Activity, Board, Card, KanbanList, Membership}
  alias Tasker.Repo

  @default_lists ["Backlog", "In Progress", "Review", "Done"]

  def topic(board_id), do: "boards:#{board_id}"

  def subscribe(board_id) do
    Phoenix.PubSub.subscribe(Tasker.PubSub, topic(board_id))
  end

  def list_boards do
    Board
    |> order_by([b], desc: b.inserted_at)
    |> preload([:owner, memberships: :user])
    |> Repo.all()
  end

  def get_board!(id) do
    Board
    |> Repo.get!(id)
    |> preload_board()
  end

  def change_board(%Board{} = board, attrs \\ %{}) do
    Board.changeset(board, attrs)
  end

  def create_board(attrs, %User{} = owner) do
    list_names = fetch_attr(attrs, :lists, @default_lists)
    board_attrs = put_attr(attrs, :owner_id, owner.id)

    Multi.new()
    |> Multi.insert(:board, Board.changeset(%Board{}, board_attrs))
    |> Multi.insert(:membership, fn %{board: board} ->
      Membership.changeset(%Membership{}, %{
        board_id: board.id,
        user_id: owner.id,
        role: "owner"
      })
    end)
    |> Multi.run(:lists, fn repo, %{board: board} ->
      lists =
        list_names
        |> Enum.with_index()
        |> Enum.map(fn {name, position} ->
          %KanbanList{}
          |> KanbanList.changeset(%{board_id: board.id, name: name, position: position})
          |> repo.insert!()
        end)

      {:ok, lists}
    end)
    |> Multi.insert(:activity, fn %{board: board} ->
      Activity.changeset(%Activity{}, %{
        board_id: board.id,
        actor_id: owner.id,
        action: "board.created",
        metadata: %{name: board.name}
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{board: board}} ->
        board = get_board!(board.id)
        broadcast_change(board.id, :board_created, %{board_id: board.id})
        {:ok, board}

      {:error, _step, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def update_board(%Board{} = board, attrs, %User{} = actor) do
    Multi.new()
    |> Multi.update(:board, Board.changeset(board, attrs))
    |> Multi.insert(:activity, fn %{board: changed_board} ->
      Activity.changeset(%Activity{}, %{
        board_id: changed_board.id,
        actor_id: actor.id,
        action: "board.updated",
        metadata: Map.take(attrs, [:name, :description, "name", "description"])
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{board: board}} ->
        board = get_board!(board.id)
        broadcast_change(board.id, :board_updated, %{board_id: board.id})
        {:ok, board}

      {:error, _step, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def create_list(%Board{} = board, attrs, %User{} = actor) do
    position = fetch_attr(attrs, :position, next_list_position(board.id))
    attrs =
      attrs
      |> put_attr(:board_id, board.id)
      |> put_attr(:position, position)

    Multi.new()
    |> Multi.insert(:list, KanbanList.changeset(%KanbanList{}, attrs))
    |> Multi.insert(:activity, fn %{list: list} ->
      Activity.changeset(%Activity{}, %{
        board_id: board.id,
        actor_id: actor.id,
        action: "list.created",
        metadata: %{name: list.name}
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{list: list}} ->
        broadcast_change(board.id, :list_created, %{list_id: list.id})
        {:ok, list}

      {:error, _step, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def change_card(%Card{} = card, attrs \\ %{}) do
    Card.changeset(card, attrs)
  end

  def create_card(%Board{} = board, %KanbanList{} = list, attrs, %User{} = actor) do
    attrs =
      attrs
      |> put_attr(:board_id, board.id)
      |> put_attr(:list_id, list.id)
      |> put_attr_new(:position, next_card_position(list.id))
      |> put_attr_new(:status, "open")

    Multi.new()
    |> Multi.insert(:card, Card.changeset(%Card{}, attrs))
    |> Multi.insert(:activity, fn %{card: card} ->
      Activity.changeset(%Activity{}, %{
        board_id: board.id,
        card_id: card.id,
        actor_id: actor.id,
        action: "card.created",
        metadata: %{title: card.title, list_id: list.id}
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{card: card}} ->
        broadcast_change(board.id, :card_created, %{card_id: card.id})
        {:ok, card}

      {:error, _step, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def update_card(%Card{} = card, attrs, %User{} = actor) do
    Multi.new()
    |> Multi.update(:card, Card.changeset(card, attrs))
    |> Multi.insert(:activity, fn %{card: changed_card} ->
      Activity.changeset(%Activity{}, %{
        board_id: changed_card.board_id,
        card_id: changed_card.id,
        actor_id: actor.id,
        action: "card.updated",
        metadata: Map.take(attrs, [:title, :description, :priority, :status, "title", "description", "priority", "status"])
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{card: card}} ->
        broadcast_change(card.board_id, :card_updated, %{card_id: card.id})
        {:ok, card}

      {:error, _step, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def move_card(card_id, target_list_id, requested_position, %User{} = actor) do
    card = Repo.get!(Card, card_id)
    target_list = Repo.get!(KanbanList, target_list_id)
    source_list_id = card.list_id
    position = parse_position(requested_position)

    Repo.transaction(fn ->
      reorder_cards!(target_list.id, card.id, position)

      if source_list_id != target_list.id do
        normalize_positions!(source_list_id)
      end

      %Activity{}
      |> Activity.changeset(%{
        board_id: card.board_id,
        card_id: card.id,
        actor_id: actor.id,
        action: "card.moved",
        metadata: %{
          from_list_id: source_list_id,
          to_list_id: target_list.id,
          position: position
        }
      })
      |> Repo.insert!()

      Repo.get!(Card, card.id)
    end)
    |> case do
      {:ok, moved_card} ->
        broadcast_change(moved_card.board_id, :card_moved, %{card_id: moved_card.id})
        {:ok, moved_card}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp preload_board(%Board{} = board) do
    board =
      Repo.preload(board,
        owner: [],
        memberships: [:user],
        activities: [:actor, :card],
        lists: [cards: [:assignee]]
      )

    lists =
      board.lists
      |> Enum.sort_by(& &1.position)
      |> Enum.map(fn list ->
        %{list | cards: Enum.sort_by(list.cards, & &1.position)}
      end)

    activities =
      board.activities
      |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
      |> Enum.take(25)

    %{board | lists: lists, activities: activities}
  end

  defp broadcast_change(board_id, event, payload) do
    Phoenix.PubSub.broadcast(Tasker.PubSub, topic(board_id), {__MODULE__, event, payload})
  end

  defp next_list_position(board_id) do
    from(l in KanbanList, where: l.board_id == ^board_id, select: max(l.position))
    |> Repo.one()
    |> next_position()
  end

  defp next_card_position(list_id) do
    from(c in Card, where: c.list_id == ^list_id, select: max(c.position))
    |> Repo.one()
    |> next_position()
  end

  defp next_position(nil), do: 0
  defp next_position(position), do: position + 1

  defp reorder_cards!(target_list_id, moved_card_id, requested_position) do
    cards =
      Card
      |> where([c], c.list_id == ^target_list_id and c.id != ^moved_card_id)
      |> order_by([c], asc: c.position, asc: c.inserted_at)
      |> Repo.all()

    moved_card = Repo.get!(Card, moved_card_id)
    position = requested_position |> max(0) |> min(length(cards))
    {before, after_cards} = Enum.split(cards, position)

    before
    |> Enum.concat([moved_card | after_cards])
    |> Enum.with_index()
    |> Enum.each(fn {card, position} ->
      update_card_position!(card, target_list_id, position)
    end)
  end

  defp normalize_positions!(list_id) do
    Card
    |> where([c], c.list_id == ^list_id)
    |> order_by([c], asc: c.position, asc: c.inserted_at)
    |> Repo.all()
    |> Enum.with_index()
    |> Enum.each(fn {card, position} ->
      update_card_position!(card, list_id, position)
    end)
  end

  defp update_card_position!(card, list_id, position) do
    now = DateTime.utc_now(:second)

    Card
    |> where([c], c.id == ^card.id)
    |> Repo.update_all(set: [list_id: list_id, position: position, updated_at: now])
  end

  defp parse_position(position) when is_integer(position), do: position

  defp parse_position(position) when is_binary(position) do
    case Integer.parse(position) do
      {value, _rest} -> value
      :error -> 0
    end
  end

  defp parse_position(_position), do: 0

  defp fetch_attr(attrs, key, default) do
    Map.get(attrs, key) || Map.get(attrs, Atom.to_string(key)) || default
  end

  defp put_attr(attrs, key, value) do
    if string_keyed?(attrs) do
      Map.put(attrs, Atom.to_string(key), value)
    else
      Map.put(attrs, key, value)
    end
  end

  defp put_attr_new(attrs, key, value) do
    if fetch_attr(attrs, key, nil) do
      attrs
    else
      put_attr(attrs, key, value)
    end
  end

  defp string_keyed?(attrs), do: Enum.any?(Map.keys(attrs), &is_binary/1)
end
