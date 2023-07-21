defmodule Boxing.PromptsTest do
  use Boxing.DataCase

  alias Boxing.Prompts

  describe "prompt" do
    alias Boxing.Prompts.Prompt

    import Boxing.PromptsFixtures

    @invalid_attrs %{completion: nil, model: nil, time: nil, version: nil}

    test "list_prompt/0 returns all prompt" do
      prompt = prompt_fixture()
      assert Prompts.list_prompts() == [prompt]
    end

    test "get_prompt!/1 returns the prompt with given id" do
      prompt = prompt_fixture()
      assert Prompts.get_prompt!(prompt.id) == prompt
    end

    test "create_prompt/1 with valid data creates a prompt" do
      valid_attrs = %{
        completion: "some completion",
        model: "some model",
        time: 120.5,
        version: "some version"
      }

      assert {:ok, %Prompt{} = prompt} = Prompts.create_prompt(valid_attrs)
      assert prompt.completion == "some completion"
      assert prompt.model == "some model"
      assert prompt.time == 120.5
      assert prompt.version == "some version"
    end

    test "create_prompt/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Prompts.create_prompt(@invalid_attrs)
    end

    test "update_prompt/2 with valid data updates the prompt" do
      prompt = prompt_fixture()

      update_attrs = %{
        completion: "some updated completion",
        model: "some updated model",
        time: 456.7,
        version: "some updated version"
      }

      assert {:ok, %Prompt{} = prompt} = Prompts.update_prompt(prompt, update_attrs)
      assert prompt.completion == "some updated completion"
      assert prompt.model == "some updated model"
      assert prompt.time == 456.7
      assert prompt.version == "some updated version"
    end

    test "update_prompt/2 with invalid data returns error changeset" do
      prompt = prompt_fixture()
      assert {:error, %Ecto.Changeset{}} = Prompts.update_prompt(prompt, @invalid_attrs)
      assert prompt == Prompts.get_prompt!(prompt.id)
    end

    test "delete_prompt/1 deletes the prompt" do
      prompt = prompt_fixture()
      assert {:ok, %Prompt{}} = Prompts.delete_prompt(prompt)
      assert_raise Ecto.NoResultsError, fn -> Prompts.get_prompt!(prompt.id) end
    end

    test "change_prompt/1 returns a prompt changeset" do
      prompt = prompt_fixture()
      assert %Ecto.Changeset{} = Prompts.change_prompt(prompt)
    end
  end
end
