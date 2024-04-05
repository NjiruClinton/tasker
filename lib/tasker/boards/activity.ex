defmodule Tasker.Boards.Activity do
  use Ecto.Schema

  import Ecto.Changeset

  alias Tasker.Accounts.User
  alias Tasker.Boards.{Board, Card}

  schema "activities" do
    field :action, :string
    field :metadata, :map, default: %{}

    belongs_to :actor, User
    belongs_to :board, Board
    belongs_to :card, Card

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:action, :metadata, :actor_id, :board_id, :card_id])
    |> validate_required([:action, :actor_id, :board_id])
    |> validate_inclusion(:action, [
      "board.created",
      "board.updated",
      "list.created",
      "card.created",
      "card.updated",
      "card.moved"
    ])
    |> foreign_key_constraint(:actor_id)
    |> foreign_key_constraint(:board_id)
    |> foreign_key_constraint(:card_id)
  end
end
