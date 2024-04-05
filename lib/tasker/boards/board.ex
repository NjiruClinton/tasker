defmodule Tasker.Boards.Board do
  use Ecto.Schema

  import Ecto.Changeset

  alias Tasker.Accounts.User
  alias Tasker.Boards.{Activity, Card, KanbanList, Membership}

  schema "boards" do
    field :description, :string
    field :name, :string
    field :slug, :string

    belongs_to :owner, User
    has_many :lists, KanbanList
    has_many :cards, Card
    has_many :memberships, Membership
    has_many :activities, Activity

    timestamps(type: :utc_datetime)
  end

  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name, :description, :slug, :owner_id])
    |> validate_required([:name, :owner_id])
    |> validate_length(:name, min: 3, max: 80)
    |> maybe_put_slug()
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:owner_id)
  end

  defp maybe_put_slug(changeset) do
    case {get_field(changeset, :slug), get_field(changeset, :name)} do
      {nil, name} when is_binary(name) ->
        put_change(changeset, :slug, "#{slugify(name)}-#{random_suffix()}")

      _ ->
        changeset
    end
  end

  defp slugify(value) do
    value
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
    |> case do
      "" -> "board"
      slug -> slug
    end
  end

  defp random_suffix do
    3
    |> :crypto.strong_rand_bytes()
    |> Base.encode16(case: :lower)
  end
end
