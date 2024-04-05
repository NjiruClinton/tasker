defmodule Tasker.BoardsTest do
  use Tasker.DataCase, async: true

  alias Tasker.Accounts
  alias Tasker.Boards
  alias Tasker.Boards.Card
  alias Tasker.Repo

  describe "boards" do
    test "create_board/2 creates default lists, ownership, and activity" do
      owner = user_fixture()

      assert {:ok, board} =
               Boards.create_board(
                 %{name: "Launch pipeline", description: "Coordinate release readiness"},
                 owner
               )

      assert board.owner_id == owner.id
      assert Enum.map(board.lists, & &1.name) == ["Backlog", "In Progress", "Review", "Done"]
      assert [%{role: "owner", user_id: owner_id}] = board.memberships
      assert owner_id == owner.id
      assert [%{action: "board.created"}] = board.activities
    end
  end

  describe "cards" do
    test "move_card/4 moves a card across lists and normalizes card ordering" do
      owner = user_fixture()
      {:ok, board} = Boards.create_board(%{name: "Sprint board"}, owner)

      [backlog, in_progress | _] = board.lists

      {:ok, first} = Boards.create_card(board, backlog, %{title: "Write specs"}, owner)
      {:ok, second} = Boards.create_card(board, backlog, %{title: "Build board"}, owner)
      {:ok, third} = Boards.create_card(board, in_progress, %{title: "Pair review"}, owner)

      assert {:ok, %Card{} = moved} = Boards.move_card(first.id, in_progress.id, 0, owner)
      assert moved.list_id == in_progress.id

      board = Boards.get_board!(board.id)
      backlog = Enum.find(board.lists, &(&1.id == backlog.id))
      in_progress = Enum.find(board.lists, &(&1.id == in_progress.id))

      assert Enum.map(backlog.cards, &{&1.id, &1.position}) == [{second.id, 0}]
      assert Enum.map(in_progress.cards, &{&1.id, &1.position}) == [{first.id, 0}, {third.id, 1}]
      assert hd(board.activities).action == "card.moved"
    end
  end

  defp user_fixture(attrs \\ %{}) do
    suffix = System.unique_integer([:positive])

    defaults = %{
      name: "Ada Lovelace",
      email: "ada-#{suffix}@example.com",
      handle: "ada_#{suffix}"
    }

    {:ok, user} = Accounts.create_user(Map.merge(defaults, attrs))
    user
  end
end
