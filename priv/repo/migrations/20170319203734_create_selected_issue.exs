defmodule Estimator.Repo.Migrations.CreateSelectedIssue do
  use Ecto.Migration

  def change do
    create table(:selected_issues) do
      add :key, :string
      add :link, :string
      add :selected, :boolean, default: false, null: false
      add :summary, :string
      add :description, :text
      add :raw, :map

      timestamps()
    end

  end
end

