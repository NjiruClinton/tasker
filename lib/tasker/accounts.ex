defmodule Tasker.Accounts do
  @moduledoc """
  Small account boundary used by the collaborative board experience.

  Tasker keeps authentication intentionally out of scope. The context still models
  real users so boards, memberships, assignments, and activity history behave like
  a production Phoenix app would.
  """

  alias Tasker.Accounts.User
  alias Tasker.Repo

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def ensure_demo_user do
    attrs = %{
      name: "Demo Teammate",
      email: "demo@tasker.local",
      handle: "demo"
    }

    Repo.get_by(User, email: attrs.email) ||
      case create_user(attrs) do
        {:ok, user} -> user
        {:error, _changeset} -> Repo.get_by!(User, email: attrs.email)
      end
  end
end
