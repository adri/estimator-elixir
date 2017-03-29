defmodule Estimator.Votes do
  import Ecto.Query

  alias Estimator.Repo
  alias Estimator.Vote.Vote

  @spec insert_vote(map) ::
      {:ok, Vote.t} |
      {:error, Ecto.Changeset.t}
  def insert_vote(params) do
    %Vote{}
    |> Vote.changeset(params)
    |> Repo.insert
  end

  def for_topic_and_issue(topic, issue_key) do
      Vote
      |> select([c], map(c, [:user_id, :vote]))
      |> where(topic: ^topic)
      |> where(issue_key: ^issue_key)
      |> distinct(:user_id)
      |> order_by(desc: :inserted_at)
      |> Repo.all
      |> Enum.group_by(&(&1.user_id))
      |> Enum.map(fn {user_id, vote} ->
        { user_id, List.first(vote).vote }
      end)
      |> Enum.into(%{})
  end
end
