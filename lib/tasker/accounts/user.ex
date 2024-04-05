defmodule Tasker.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Tasker.Boards.{Board, Card, Membership}

  schema "users" do
    field :email, :string
    field :handle, :string
    field :name, :string

    has_many :owned_boards, Board, foreign_key: :owner_id
    has_many :memberships, Membership
    has_many :assigned_cards, Card, foreign_key: :assignee_id

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :handle])
    |> validate_required([:name, :email, :handle])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_format(:handle, ~r/^[a-z0-9_]+$/)
    |> update_change(:email, &String.downcase/1)
    |> update_change(:handle, &String.downcase/1)
    |> unique_constraint(:email)
    |> unique_constraint(:handle)
  end
end
