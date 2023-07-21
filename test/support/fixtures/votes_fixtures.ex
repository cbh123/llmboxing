defmodule Boxing.VotesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Boxing.Votes` context.
  """

  @doc """
  Generate a vote.
  """
  def vote_fixture(attrs \\ %{}) do
    {:ok, vote} =
      attrs
      |> Enum.into(%{

      })
      |> Boxing.Votes.create_vote()

    vote
  end
end
