defmodule Tasker.Repo.Migrations.CreateBoardMemberships do
  use Ecto.Migration

  def change do
    create table(:board_memberships) do
      add :role, :string, null: false, default: "viewer"
      add :board_id, references(:boards, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:board_memberships, [:board_id])
    create index(:board_memberships, [:user_id])
    create unique_index(:board_memberships, [:board_id, :user_id])
  end
end
