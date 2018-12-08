defmodule Calibration do
  def get_input_as_number_list() do
    File.stream!("./input.txt", [], :line)
    |> Enum.map(fn s -> s |> String.trim() |> String.to_integer() end)
  end

  def sum_input() do
    get_input_as_number_list()
    |> Enum.sum()
    |> inspect()
  end

  def first_double_frequency() do
    get_input_as_number_list()
    |> Stream.cycle()
    |> Enum.reduce_while({MapSet.new(), 0}, fn i, {seen_frequencies, current_frequency} ->
      current_frequency = current_frequency + i

      if MapSet.member?(seen_frequencies, current_frequency) do
        {:halt, current_frequency}
      else
        {:cont, {MapSet.put(seen_frequencies, current_frequency), current_frequency}}
      end
    end)
    |> inspect()
  end
end
