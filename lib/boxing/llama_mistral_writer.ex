defmodule Boxing.LlamaMistralWriter do
  @moduledoc """
  GenServer for writing the questions
  """
  use GenServer
  alias Boxing.Prompts
  @fight_name "llama-vs-mistral"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_creation()
    {:ok, state}
  end

  defp should_work?() do
    case Application.get_env(:boxing, :env) do
      :prod -> Prompts.count_prompts_by_fight(@fight_name) < 1000
      :dev -> Prompts.count_prompts_by_fight(@fight_name) < 50
      _ -> false
    end
  end

  def handle_info(:create, state) do
    if should_work?() do
      questions = Prompts.create_questions()

      questions
      |> Enum.each(fn q ->
        Prompts.generate_text_completions(
          "#{q}. Answer as succintly as possible. Maximum response length of 1 paragraph.",
          ["mistral-7b-instruct-v0.1", "llama-2-13b-chat"],
          @fight_name
        )
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
