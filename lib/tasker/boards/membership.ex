defmodule Tasker.Boards.Membership do
  use Ecto.Schema

  import Ecto.Changeset

  alias Tasker.Accounts.User
  alias Tasker.Boards.Board

  @roles ~w(owner admin editor viewer)

  schema "board_memberships" do
    field :role, :string, default: "viewer"

    belongs_to :board, Board
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:role, :board_id, :user_id])
    |> validate_required([:role, :board_id, :user_id])
    |> validate_inclusion(:role, @roles)
    |> unique_constraint([:board_id, :user_id])
    |> foreign_key_constraint(:board_id)
    |> foreign_key_constraint(:user_id)
  end
end
