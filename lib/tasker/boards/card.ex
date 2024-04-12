defmodule Tasker.Boards.Card do
  use Ecto.Schema

  import Ecto.Changeset

  alias Tasker.Accounts.User
  alias Tasker.Boards.{Activity, Board, KanbanList}

  @priorities ~w(low medium high)
  @statuses ~w(open blocked done)

  schema "cards" do
    field :description, :string
    field :due_on, :date
    field :labels, {:array, :string}, default: []
    field :position, :integer, default: 0
    field :priority, :string, default: "medium"
    field :status, :string, default: "open"
    field :title, :string

    belongs_to :assignee, User
    belongs_to :board, Board
    belongs_to :list, KanbanList
    has_many :activities, Activity

    timestamps(type: :utc_datetime)
  end

  def changeset(card, attrs) do
    card
    |> cast(normalize_labels(attrs), [
      :title,
      :description,
      :priority,
      :status,
      :position,
      :due_on,
      :labels,
      :assignee_id,
      :board_id,
      :list_id
    ])
    |> validate_required([:title, :priority, :status, :position, :board_id, :list_id])
    |> validate_length(:title, min: 3, max: 120)
    |> validate_inclusion(:priority, @priorities)
    |> validate_inclusion(:status, @statuses)
    |> validate_number(:position, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:assignee_id)
    |> foreign_key_constraint(:board_id)
      |> foreign_key_constraint(:list_id)
  end

  defp normalize_labels(%{"labels" => labels} = attrs) when is_binary(labels) do
    Map.put(attrs, "labels", split_labels(labels))
  end

  defp normalize_labels(%{labels: labels} = attrs) when is_binary(labels) do
    Map.put(attrs, :labels, split_labels(labels))
  end

  defp normalize_labels(attrs), do: attrs

  defp split_labels(labels) do
    labels
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end
end
