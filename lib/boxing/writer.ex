defmodule Boxing.Writer do
  @moduledoc """
  GenServer for writing the questions
  """
  use GenServer
  alias Boxing.Prompts
  import Config.Reader

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_creation()
    {:ok, state}
  end

  def handle_info(:create, state) do
    if Application.get_env(:boxing, :env) == :prod and Prompts.count_prompts("language") < 1500 do
      questions = Prompts.create_questions()

      questions
      |> Enum.each(fn q ->
        Prompts.generate_text_completions(
          "#{q}. Answer as succintly as possible. Maximum response length of 1 paragraph."
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
