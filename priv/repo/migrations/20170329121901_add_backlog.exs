defmodule Estimator.Repo.Migrations.AddBacklog do
  use Ecto.Migration

  def change do
    alter table(:selected_issues) do
      add :board_id, :integer
    end
  end
end
