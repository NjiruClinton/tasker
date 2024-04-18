defmodule Tasker.Repo.Migrations.CreateBoards do
  use Ecto.Migration

  def change do
    create table(:boards) do
      add :name, :string, null: false
      add :description, :text
      add :slug, :string, null: false
      add :owner_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:boards, [:slug])
    create index(:boards, [:owner_id])
  end
end
