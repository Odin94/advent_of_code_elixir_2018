defmodule License do
  def parse_meta_data() do
    get_input_as_number_list()
    |> do_parse_meta_data([], [])
    # reverse optional, order doesn't matter for puzzle
    |> Enum.reverse()
    |> Enum.sum()
  end

  def test_parse() do
    IO.puts("Should be 138")

    ~w(2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2)
    |> Enum.map(&String.to_integer/1)
    |> do_parse_meta_data([], [])
    # reverse optional, order doesn't matter for puzzle
    |> Enum.reverse()
    |> Enum.sum()
  end

  def get_root_value() do
    # get_input_as_number_list()
    # root: {1 -> 33, 2 -> 0}, [1, 1, 2]
    # ~w(2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2)
    # |> Enum.map(&String.to_integer/1)
    get_input_as_number_list()
    |> get_value_and_numbers()
    |> elem(0)
  end

  def get_value_and_numbers([]) do
    # IO.puts("Empty list!")
    {0, []}
  end

  # value for nodes without children
  def get_value_and_numbers([0, meta_count | numbers]) do
    {meta_data, numbers} = get_meta_data_and_numbers(meta_count, numbers)
    value = Enum.sum(meta_data)

    IO.puts("childless node, value: #{value}")

    {value, numbers}
  end

  # value and numbers minus the ones consumed by child nodes
  def get_value_and_numbers([child_count, meta_count | numbers]) do
    IO.puts("node with #{child_count} children..")

    {children_by_position, numbers} = get_children_by_position_and_numbers(child_count, numbers)

    {meta_data, numbers} = get_meta_data_and_numbers(meta_count, numbers)
    value = get_value_from_childnodes_and_metadata(children_by_position, meta_data)

    IO.inspect(".. and value #{value}. Remaining numbers: ")
    IO.inspect(numbers)
    IO.inspect(children_by_position)

    {value, numbers}
  end

  def get_children_by_position_and_numbers(child_count, numbers) do
    1..child_count
    |> Enum.reduce({%{}, numbers}, fn i, {children_by_position, numbers} ->
      IO.puts("current child: #{i} of #{child_count}")
      {value, numbers} = get_value_and_numbers(numbers)

      {Map.put(children_by_position, i, value), numbers}
    end)
  end

  def get_value_from_childnodes_and_metadata(children_by_position, meta_data) do
    Enum.reduce(meta_data, 0, fn node_position, acc ->
      case Map.get(children_by_position, node_position, nil) do
        nil -> acc
        value -> acc + value
      end
    end)
  end

  def get_meta_data_and_numbers(meta_count, numbers) do
    meta_data = Enum.take(numbers, meta_count)
    numbers = Enum.slice(numbers, meta_count..-1)

    {meta_data, numbers}
  end

  def do_parse_meta_data([], super_nodes, meta_data), do: meta_data

  def do_parse_meta_data([0, meta_count | numbers], super_nodes, meta_data) do
    meta_data = [Enum.take(numbers, meta_count) | meta_data] |> List.flatten()
    numbers = Enum.slice(numbers, meta_count..-1)

    {numbers, super_nodes, meta_data} = apply_super_nodes(numbers, super_nodes, meta_data)

    do_parse_meta_data(numbers, super_nodes, meta_data)
  end

  def do_parse_meta_data([subnode_count, meta_count | numbers], super_nodes, meta_data) do
    super_nodes = [{subnode_count, meta_count} | super_nodes]

    do_parse_meta_data(numbers, super_nodes, meta_data)
  end

  def apply_super_nodes([], super_nodes, meta_data) do
    {[], super_nodes, meta_data}
  end

  def apply_super_nodes(numbers, [{0, meta_count} | super_nodes], meta_data) do
    meta_data = [Enum.take(numbers, meta_count) | meta_data] |> List.flatten()
    numbers = Enum.slice(numbers, meta_count..-1)

    apply_super_nodes(numbers, super_nodes, meta_data)
  end

  def apply_super_nodes(numbers, [{1, meta_count} | super_nodes], meta_data) do
    apply_super_nodes(numbers, [{0, meta_count} | super_nodes], meta_data)
  end

  def apply_super_nodes(numbers, [{subnode_count, meta_count} | super_nodes], meta_data) do
    subnode_count = subnode_count - 1
    {numbers, [{subnode_count, meta_count} | super_nodes], meta_data}
  end

  def get_input_as_number_list() do
    File.stream!("./input.txt", [], :line)
    |> Enum.map(fn s -> s |> String.trim() end)
    |> List.first()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end

# 35852
