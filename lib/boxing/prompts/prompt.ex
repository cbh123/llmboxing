defmodule Boxing.Prompts.Prompt do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prompts" do
    field :prompt, :string
    field :completion, :string
    field :model, :string
    field :time, :float
    field :version, :string
    field :submission_id, :binary_id
    field :votes, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(prompt, attrs) do
    prompt
    |> cast(attrs, [:prompt, :completion, :model, :version, :time, :submission_id, :votes])
    |> validate_required([:prompt, :completion, :model, :version, :time, :submission_id])
  end
end
