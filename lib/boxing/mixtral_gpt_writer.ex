defmodule Boxing.MixtralGPTWriter do
  @moduledoc """
  GenServer for writing the questions
  """
  use GenServer
  alias Boxing.Prompts
  @fight_name "mixtral-vs-gpt"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_creation()
    {:ok, state}
  end

  defp should_work?() do
    case Application.get_env(:boxing, :env) do
      :prod -> Prompts.count_prompts_by_fight(@fight_name) < 50
      :dev -> Prompts.count_prompts_by_fight(@fight_name) < 50
      _ -> false
    end
  end

  def handle_info(:create, state) do
    if should_work?() do
      IO.puts("Creating prompts for mixtral-vs-gpt")
      questions = Prompts.create_questions()

      questions
      |> Enum.each(fn q ->
        submission_id = Ecto.UUID.generate()

        {:ok, _prompt} =
          Prompts.gen(%{
            model: "mixtral-8x7b",
            question: "#{q}. Answer as succinctly as possible. No more than 100 words.",
            submission_id: submission_id,
            fight_name: @fight_name
          })

        {:ok, _prompt} =
          Prompts.gen(%{
            model: "gpt-3.5-turbo",
            question: "#{q}. Answer as succinctly as possible. No more than 1 paragraph.",
            submission_id: submission_id,
            fight_name: @fight_name
          })
      end)

      schedule_creation()
    end

    {:noreply, state}
  end

  defp schedule_creation() do
    # Every 5 seconds
    Process.send_after(self(), :create, 5000)
  end
end
