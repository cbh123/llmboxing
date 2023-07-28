defmodule Boxing.Drawer do
  @moduledoc """
  GenServer for making image prompts
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
    if Application.get_env(:boxing, :env) == :prod and Prompts.count_prompts("image") < 5 do
      prompts = Prompts.create_image_prompts()

      prompts
      |> Enum.each(fn p ->
        Prompts.generate_images(p)
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
