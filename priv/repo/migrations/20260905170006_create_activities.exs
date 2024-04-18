defmodule Tasker.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities) do
      add :action, :string, null: false
      add :metadata, :map, null: false, default: %{}
      add :actor_id, references(:users, on_delete: :nilify_all)
      add :board_id, references(:boards, on_delete: :delete_all), null: false
      add :card_id, references(:cards, on_delete: :nilify_all)

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:activities, [:board_id, :inserted_at])
    create index(:activities, [:actor_id])
    create index(:activities, [:card_id])
  end
end
