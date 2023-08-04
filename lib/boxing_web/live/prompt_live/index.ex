defmodule BoxingWeb.PromptLive.Index do
  use BoxingWeb, :live_view

  alias Boxing.Prompts
  alias Boxing.Prompts.Prompt

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"type" => type}, _url, socket) do
    {:noreply, stream(socket, :prompt_collection, Prompts.list_prompts(type))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     apply_action(socket, socket.assigns.live_action, params)
     |> stream(:prompt_collection, Prompts.list_prompts())}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Prompt")
    |> assign(:prompt, Prompts.get_prompt!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Prompt")
    |> assign(:prompt, %Prompt{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Prompt")
    |> assign(:prompt, nil)
  end

  @impl true
  def handle_info({BoxingWeb.PromptLive.FormComponent, {:saved, prompt}}, socket) do
    {:noreply, stream_insert(socket, :prompt_collection, prompt)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    prompt = Prompts.get_prompt!(id)
    {:ok, _} = Prompts.delete_prompt(prompt)

    {:noreply, stream_delete(socket, :prompt_collection, prompt)}
  end

  def handle_event("run-mj", _, socket) do
    Prompts.add()
    {:noreply, socket}
  end
end
