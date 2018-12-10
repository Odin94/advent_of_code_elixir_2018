defmodule Polymer do
  def shortest_polymer_with_removal() do
    letters = get_input() |> String.graphemes()

    for filtered_letter <- ~w(a b c d) do
      get_polymer_lengths_for_filter(letters, filtered_letter)
    end
    |> Enum.min()
  end

  def react() do
    get_input()
    |> String.graphemes()
    |> iterate_react()
    |> Enum.count()
  end

  # Naive solution: keep filtering until no units react in a pass
  def iterate_react(letters) do
    reacted = do_react(letters, [])

    if length(reacted) == length(letters) do
      reacted
    else
      iterate_react(reacted)
    end
  end

  def do_react([head, next | tail], acc) do
    if should_react?(head, next) do
      do_react(tail, acc)
    else
      do_react([next | tail], [head | acc])
    end
  end

  def do_react([head | tail], acc), do: do_react(tail, [head | acc])

  def do_react([], acc), do: Enum.reverse(acc)

  def should_react?(a, b), do: a != b and String.upcase(a) == String.upcase(b)

  def get_polymer_lengths_for_filter(letters, filtered_character_lowercase) do
    letters
    |> Enum.reject(fn letter -> String.downcase(letter) == filtered_character_lowercase end)
    |> iterate_react()
    |> Enum.count()
  end

  def get_input() do
    File.stream!("./input.txt", [], :line)
    |> Enum.map(&String.trim/1)
    |> List.first()
  end
end
