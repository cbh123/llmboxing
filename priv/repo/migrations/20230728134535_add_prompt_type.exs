defmodule Boxing.Repo.Migrations.AddPromptType do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      add(:prompt_type, :string, default: "language")
      add(:output, :string)
    end
  end
end
