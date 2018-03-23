defmodule Estimator.Repo.Migrations.AddSelectedIssuesUniqueKey do
  use Ecto.Migration

  def change do
    # Clean up duplicates
    execute """
      DELETE
        FROM
          selected_issues a
        USING selected_issues b
        WHERE
          a.id < b.id
          AND a.key = b.key;
    """
    create unique_index(:selected_issues, [:key])
  end
end
