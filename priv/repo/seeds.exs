import Ecto.Query

alias Tasker.Accounts
alias Tasker.Boards
alias Tasker.Boards.{Board, Card}
alias Tasker.Repo

owner = Accounts.ensure_demo_user()

board =
  case Repo.get_by(Board, name: "Product Discovery") do
    nil ->
      {:ok, board} =
        Boards.create_board(
          %{
            name: "Product Discovery",
            description: "Research, prototype, and launch readiness for a focused product team"
          },
          owner
        )

      board

    board ->
      Boards.get_board!(board.id)
  end

cards = [
  {"Interview customers", "Backlog", "high", ["research", "customer"]},
  {"Map onboarding states", "Backlog", "medium", ["ux"]},
  {"Prototype board presence", "In Progress", "high", ["liveview", "realtime"]},
  {"Review migration constraints", "Review", "medium", ["ecto"]},
  {"Publish demo notes", "Done", "low", ["docs"]}
]

for {title, list_name, priority, labels} <- cards do
  list = Enum.find(board.lists, &(&1.name == list_name))

  exists? =
    Repo.exists?(
      from c in Card,
        where: c.board_id == ^board.id and c.title == ^title
    )

  unless exists? do
    {:ok, _card} =
      Boards.create_card(
        board,
        list,
        %{
          title: title,
          priority: priority,
          labels: labels,
          description: "Seeded demo card for the portfolio walkthrough"
        },
        owner
      )
  end
end
