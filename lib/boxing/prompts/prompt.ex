defmodule Boxing.Prompts.Prompt do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prompts" do
    field(:prompt, :string)
    field(:completion, :string)
    field(:model, :string)
    field(:time, :float)
    field(:version, :string)
    field(:submission_id, :binary_id)
    field(:votes, :integer, default: 0)
    # model type has to be "image" or "language"
    field(:model_type, :string, default: "language")
    field(:output, :string)

    timestamps()
  end

  @doc false
  def changeset(prompt, attrs) do
    prompt
    |> cast(attrs, [
      :prompt,
      :completion,
      :model,
      :version,
      :time,
      :submission_id,
      :votes,
      :model_type,
      :output
    ])
    |> validate_inclusion(:model_type, ["image", "language"])
    |> validate_required([
      :prompt,
      :model,
      :version,
      :time,
      :submission_id,
      :model_type
    ])
  end
end
