defmodule Boxing.Repo.Migrations.AddVotes do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      add :votes, :integer, default: 0
    end
  end
end
