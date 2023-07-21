defmodule Boxing.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :prompt_id, references(:prompts, on_delete: :nothing)

      timestamps()
    end

    create index(:votes, [:prompt_id])
  end
end
