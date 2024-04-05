defmodule Tasker.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :title, :string, null: false
      add :description, :text
      add :priority, :string, null: false, default: "medium"
      add :status, :string, null: false, default: "open"
      add :position, :integer, null: false, default: 0
      add :due_on, :date
      add :labels, {:array, :string}, null: false, default: []
      add :assignee_id, references(:users, on_delete: :nilify_all)
      add :board_id, references(:boards, on_delete: :delete_all), null: false
      add :list_id, references(:board_lists, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:cards, [:assignee_id])
    create index(:cards, [:board_id])
    create index(:cards, [:list_id, :position])
    create index(:cards, [:status])
  end
end
