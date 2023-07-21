defmodule Boxing.PromptsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Boxing.Prompts` context.
  """

  @doc """
  Generate a prompt.
  """
  def prompt_fixture(attrs \\ %{}) do
    {:ok, prompt} =
      attrs
      |> Enum.into(%{
        completion: "some completion",
        model: "some model",
        time: 120.5,
        version: "some version"
      })
      |> Boxing.Prompts.create_prompt()

    prompt
  end
end
