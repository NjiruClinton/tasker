defmodule Tasker.Boards.KanbanList do
  use Ecto.Schema

  import Ecto.Changeset

  alias Tasker.Boards.{Board, Card}

  schema "board_lists" do
    field :name, :string
    field :position, :integer, default: 0

    belongs_to :board, Board
    has_many :cards, Card, foreign_key: :list_id

    timestamps(type: :utc_datetime)
  end

  def changeset(list, attrs) do
    list
    |> cast(attrs, [:name, :position, :board_id])
    |> validate_required([:name, :position, :board_id])
    |> validate_length(:name, min: 2, max: 50)
    |> validate_number(:position, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:board_id)
  end
end
