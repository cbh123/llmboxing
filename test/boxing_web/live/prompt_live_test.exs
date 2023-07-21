defmodule BoxingWeb.PromptLiveTest do
  use BoxingWeb.ConnCase

  import Phoenix.LiveViewTest
  import Boxing.PromptsFixtures

  @create_attrs %{completion: "some completion", model: "some model", time: 120.5, version: "some version"}
  @update_attrs %{completion: "some updated completion", model: "some updated model", time: 456.7, version: "some updated version"}
  @invalid_attrs %{completion: nil, model: nil, time: nil, version: nil}

  defp create_prompt(_) do
    prompt = prompt_fixture()
    %{prompt: prompt}
  end

  describe "Index" do
    setup [:create_prompt]

    test "lists all prompt", %{conn: conn, prompt: prompt} do
      {:ok, _index_live, html} = live(conn, ~p"/prompt")

      assert html =~ "Listing Prompt"
      assert html =~ prompt.completion
    end

    test "saves new prompt", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/prompt")

      assert index_live |> element("a", "New Prompt") |> render_click() =~
               "New Prompt"

      assert_patch(index_live, ~p"/prompt/new")

      assert index_live
             |> form("#prompt-form", prompt: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#prompt-form", prompt: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/prompt")

      html = render(index_live)
      assert html =~ "Prompt created successfully"
      assert html =~ "some completion"
    end

    test "updates prompt in listing", %{conn: conn, prompt: prompt} do
      {:ok, index_live, _html} = live(conn, ~p"/prompt")

      assert index_live |> element("#prompt-#{prompt.id} a", "Edit") |> render_click() =~
               "Edit Prompt"

      assert_patch(index_live, ~p"/prompt/#{prompt}/edit")

      assert index_live
             |> form("#prompt-form", prompt: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#prompt-form", prompt: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/prompt")

      html = render(index_live)
      assert html =~ "Prompt updated successfully"
      assert html =~ "some updated completion"
    end

    test "deletes prompt in listing", %{conn: conn, prompt: prompt} do
      {:ok, index_live, _html} = live(conn, ~p"/prompt")

      assert index_live |> element("#prompt-#{prompt.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#prompt-#{prompt.id}")
    end
  end

  describe "Show" do
    setup [:create_prompt]

    test "displays prompt", %{conn: conn, prompt: prompt} do
      {:ok, _show_live, html} = live(conn, ~p"/prompt/#{prompt}")

      assert html =~ "Show Prompt"
      assert html =~ prompt.completion
    end

    test "updates prompt within modal", %{conn: conn, prompt: prompt} do
      {:ok, show_live, _html} = live(conn, ~p"/prompt/#{prompt}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Prompt"

      assert_patch(show_live, ~p"/prompt/#{prompt}/show/edit")

      assert show_live
             |> form("#prompt-form", prompt: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#prompt-form", prompt: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/prompt/#{prompt}")

      html = render(show_live)
      assert html =~ "Prompt updated successfully"
      assert html =~ "some updated completion"
    end
  end
end
