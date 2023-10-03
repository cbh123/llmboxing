defmodule Boxing.Repo.Migrations.AddSystemPrompt do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      add :system_prompt, :text
    end
  end
end
