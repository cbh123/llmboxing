defmodule Boxing.Repo.Migrations.CreatePrompt do
  use Ecto.Migration

  def change do
    create table(:prompts) do
      add :prompt, :text
      add :completion, :text
      add :model, :string
      add :version, :string
      add :time, :float

      timestamps()
    end
  end
end
