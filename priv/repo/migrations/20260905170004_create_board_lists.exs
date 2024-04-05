defmodule Tasker.Repo.Migrations.CreateBoardLists do
  use Ecto.Migration

  def change do
    create table(:board_lists) do
      add :name, :string, null: false
      add :position, :integer, null: false, default: 0
      add :board_id, references(:boards, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:board_lists, [:board_id])
    create index(:board_lists, [:board_id, :position])
  end
end
