defmodule Estimator.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :topic, :string
      add :link, :string
      add :issue_key, :string
      add :user_id, :string
      add :vote, :string

      timestamps()
    end

  end
end
