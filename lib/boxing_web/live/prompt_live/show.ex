defmodule BoxingWeb.PromptLive.Show do
  use BoxingWeb, :live_view

  alias Boxing.Prompts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:prompt, Prompts.get_prompt!(id))}
  end

  defp page_title(:show), do: "Show Prompt"
  defp page_title(:edit), do: "Edit Prompt"
end
