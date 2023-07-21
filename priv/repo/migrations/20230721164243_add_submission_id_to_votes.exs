defmodule Boxing.Repo.Migrations.AddSubmissionIdToVotes do
  use Ecto.Migration

  def change do
    alter table(:votes) do
      add :submission_id, :binary_id
    end
  end
end
