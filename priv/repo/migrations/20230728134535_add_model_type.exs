defmodule Boxing.Repo.Migrations.AddModelType do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      add(:model_type, :string, default: "language")
      add(:output, :string)
    end
  end
end
