defmodule Inventory do
  def find_boxes() do
    input_as_grapheme_list =
      get_input_as_list()
      |> Enum.map(&String.graphemes/1)

    Enum.reduce_while(input_as_grapheme_list, {input_as_grapheme_list, []}, fn word,
                                                                               {[head | tail] =
                                                                                  remaining_words,
                                                                                result} ->
      case find_matching_boxes(word, remaining_words) do
        [] -> {:cont, {tail, []}}
        shared_letters -> {:halt, {tail, shared_letters}}
      end
    end)
    |> elem(1)
  end

  def find_matching_boxes(word, [head | tail]) do
    if differing_letter_count(word, head) == 1 do
      get_shared_letters(word, head)
    else
      find_matching_boxes(word, tail)
    end
  end

  def find_matching_boxes(word, [head | tail]), do: []
  def find_matching_boxes(word, []), do: []

  def differing_letter_count(letters_1, letters_2) do
    letters_1
    |> Enum.zip(letters_2)
    |> Enum.reduce(0, fn {a, b}, acc ->
      if a == b do
        acc
      else
        acc + 1
      end
    end)
  end

  def get_shared_letters(letters_1, letters_2) do
    letters_1
    |> Enum.zip(letters_2)
    |> Enum.reduce("", fn {a, b}, acc ->
      if a == b do
        acc <> a
      else
        acc
      end
    end)
  end

  def get_checksum() do
    get_input_as_list()
    |> Enum.map(&letter_counts/1)
    |> Enum.map(&two_three_both_none/1)
    |> Enum.reduce([0, 0], fn atom, [twos, threes] ->
      case atom do
        :both -> [twos + 1, threes + 1]
        :two -> [twos + 1, threes]
        :three -> [twos, threes + 1]
        _ -> [twos, threes]
      end
    end)
    |> Enum.reduce(1, fn i, acc -> i * acc end)
  end

  def get_input_as_list() do
    File.stream!("./input.txt", [], :line)
    |> Enum.map(fn s -> s |> String.trim() end)
  end

  def two_three_both_none(letter_count) do
    values = Map.values(letter_count)

    cond do
      Enum.member?(values, 2) and Enum.member?(values, 3) -> :both
      Enum.member?(values, 2) -> :two
      Enum.member?(values, 3) -> :three
      true -> :none
    end
  end

  def letter_counts(word) do
    word
    |> String.graphemes()
    |> Enum.reduce(%{}, fn letter, acc ->
      Map.update(acc, letter, 1, &(&1 + 1))
    end)
  end
end
