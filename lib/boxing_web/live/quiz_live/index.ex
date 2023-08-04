defmodule BoxingWeb.QuizLive.Index do
  use BoxingWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
