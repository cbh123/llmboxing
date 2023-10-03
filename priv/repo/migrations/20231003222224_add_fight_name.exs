defmodule Boxing.Repo.Migrations.AddFightName do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      add :fight_name, :string, default: "llama-vs-gpt"
    end
  end
end
