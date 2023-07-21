defmodule Boxing.Repo.Migrations.AddSubmissionId do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      add :submission_id, :binary_id
    end
  end
end
