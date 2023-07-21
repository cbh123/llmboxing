defmodule BoxingWeb.PromptLive.FormComponent do
  use BoxingWeb, :live_component

  alias Boxing.Prompts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage prompt records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="prompt-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:completion]} type="text" label="Completion" />
        <.input field={@form[:model]} type="text" label="Model" />
        <.input field={@form[:version]} type="text" label="Version" />
        <.input field={@form[:time]} type="number" label="Time" step="any" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Prompt</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{prompt: prompt} = assigns, socket) do
    changeset = Prompts.change_prompt(prompt)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"prompt" => prompt_params}, socket) do
    changeset =
      socket.assigns.prompt
      |> Prompts.change_prompt(prompt_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"prompt" => prompt_params}, socket) do
    save_prompt(socket, socket.assigns.action, prompt_params)
  end

  defp save_prompt(socket, :edit, prompt_params) do
    case Prompts.update_prompt(socket.assigns.prompt, prompt_params) do
      {:ok, prompt} ->
        notify_parent({:saved, prompt})

        {:noreply,
         socket
         |> put_flash(:info, "Prompt updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_prompt(socket, :new, prompt_params) do
    case Prompts.create_prompt(prompt_params) do
      {:ok, prompt} ->
        notify_parent({:saved, prompt})

        {:noreply,
         socket
         |> put_flash(:info, "Prompt created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
