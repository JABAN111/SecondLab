defmodule Lab2Test do
  alias SecondLab.AVLDict
  alias SecondLab.Node
  use ExUnit.Case

  @null_node %Node{key: nil, value: nil, left: nil, right: nil, height: 0}


  def balance_check(%Node{key: nil, value: nil, height: height, left: nil, right: nil}),
    do: height == 0

  def balance_check(%Node{
        key: _key,
        value: _value,
        height: height,
        left: left,
        right: right
      }) do
    balance_check(left) and balance_check(right) and height == max(left.height, right.height) + 1 and
      abs(right.height - left.height) <= 1
  end

  def remove_all(l, t) do
    {empty_t, _} =
      :lists.foldl(
        fn {k, _v}, {t_acc, l_acc} ->
          newt = AVLDict.wrap_remove(k, t_acc)
          [_ | newl] = l_acc
          assert balance_check(newt) == true
          assert :lists.usort(newl) == AVLDict.to_list(newt)
          {newt, newl}
        end,
        {t, l},
        l
      )

    assert empty_t == @null_node
  end

  test "Insert One Node" do
    node = AVLDict.insert(@null_node, 1, "1")

    expected_node = %Node{
      key: 1,
      value: "1",
      height: 1,
      left: @null_node,
      right: @null_node
    }

    assert node == expected_node and AVLDict.find(0, node) == :not_found and
             AVLDict.find(1, node) == {1, "1"}
  end

  test "Insert Two Nodes" do
    node1 = AVLDict.insert(@null_node, 1, "1")
    node2 = AVLDict.insert(node1, 2, "2")

    expected_node = %Node{
      key: 1,
      value: "1",
      height: 2,
      left: @null_node,
      right: %Node{key: 2, value: "2", height: 1, left: @null_node, right: @null_node}
    }

    assert node2 == expected_node
  end

  test "Insert Seven Nodes" do
    l = [{1, "1"}, {2, "2"}, {3, "3"}, {4, "4"}, {5, "5"}, {6, "6"}, {7, "7"}]

    expected_node = %Node{
      key: 4,
      value: "4",
      height: 3,
      left: %Node{
        key: 2,
        value: "2",
        height: 2,
        left: %Node{key: 1, value: "1", height: 1, left: @null_node, right: @null_node},
        right: %Node{key: 3, value: "3", height: 1, left: @null_node, right: @null_node}
      },
      right: %Node{
        key: 6,
        value: "6",
        height: 2,
        left: %Node{key: 5, value: "5", height: 1, left: @null_node, right: @null_node},
        right: %Node{key: 7, value: "7", height: 1, left: @null_node, right: @null_node}
      }
    }

    assert AVLDict.equal_tree(AVLDict.from_list(l), expected_node) == true
  end

# Testing node balancing functions, getting a tree from a list by left convolution, and
  # comparing trees at 50000 nodes
  test "Insert Fifty Thousands Nodes" do
    l = Enum.map(1..50_000, fn x -> {x, "#{x}"} end)
    t = AVLDict.from_list(l)
    balance_check(t)
    assert AVLDict.to_list(t) == :lists.usort(l)
  end

  # Testing the functions of getting a tree from a list by left convolution and removing 1 node by 1 node from the tree
  test "Remove One Node" do
    t = AVLDict.from_list([{1, "1"}])
    assert AVLDict.wrap_remove(1, t) == @null_node
  end

  # Testing the functions of removing 1 node from the tree on 2 nodes
  test "Remove One From Two Nodes" do
    t = AVLDict.from_list([{1, "1"}, {2, "2"}])
    assert AVLDict.to_list(AVLDict.wrap_remove(1, t)) == [{2, "2"}]
  end

  # Testing the functions of removing 1 or 2 nodes from the tree on 3 nodes
  test "Remove One Or Two From Three Nodes" do
    t = AVLDict.from_list([{1, "1"}, {2, "2"}, {3, "3"}])

    assert AVLDict.to_list(AVLDict.wrap_remove(2, t)) == [{1, "1"}, {3, "3"}] and
             AVLDict.to_list(AVLDict.wrap_remove(3, AVLDict.wrap_remove(1, t))) == [{2, "2"}]
  end

# Testing the functions of removing a non-existent node from the tree on 4 nodes
  test "Not Found Remove" do
    t = AVLDict.from_list([{1, "1"}, {2, "2"}, {3, "3"}, {4, "4"}])
    assert AVLDict.wrap_remove(5, t) == t
  end

# Testing the functions of removing all nodes from the tree on 5 nodes
  test "Remove All" do
    l = [{1, "1"}, {2, "2"}, {3, "3"}, {4, "4"}, {5, "5"}]
    t = AVLDict.from_list(l)
    remove_all(l, t)
  end

  # Testing the display of the node value multiplication function by 2 for 3 nodes with a numerical value
  test "Map Number Multiplication By Two" do
    l = [{1, 1}, {2, 2}, {3, 3}]
    expected_l = [{1, 2}, {2, 4}, {3, 6}]

    node =
      AVLDict.from_list(l)
      |> AVLDict.map(fn
        {key, value} when not is_nil(value) -> {key, value * 2}
        {key, value} -> {key, value}
      end)
      |> Enum.filter(fn {key, value} -> not is_nil(key) and not is_nil(value) end)

    assert node == expected_l
  end


# Testing a filtering function that leaves only nodes with keys greater than 1
  test "Filter More Than One" do
    l = [{1, 1}, {2, 2}, {3, 3}]
    expected_l = [{2, 2}, {3, 3}]

    node =
      AVLDict.from_list(l)
      |> AVLDict.filter(fn key, _value -> key > 1 end)

    assert node == expected_l
  end

# Testing the find function to find the value of an element with the desired key
  test "Find Node Value With Key" do
    l = [{1, 234}, {5, 1233}, {22, 1232}]
    node = AVLDict.from_list(l)
    {_, found_value} = AVLDict.find(5, node)
    assert found_value == 1233
  end

  test "Find Node With Min Key" do
    l = [{1, 100}, {2, 2}, {3, 3}]
    node = AVLDict.from_list(l)
    {min_el, _, _} = AVLDict.find_min(node)
    assert min_el.value == 100
  end

  test "Fold Left Counter" do
    l = [{1, "1"}, {2, "2"}, {3, "3"}, {4, "4"}, {5, "5"}]
    node = AVLDict.from_list(l)
    node_counter = AVLDict.foldl(node, 0, fn acc, _ -> acc + 1 end)
    assert node_counter == 5
  end

  test "Fold Right Summator" do
    l = [{1, 100}, {2, 2}, {3, 3}]
    node = AVLDict.from_list(l)

    node_summator =
      AVLDict.foldr(node, 0, fn acc, {_, value} when not is_nil(value) -> acc + value end)

    assert node_summator == 105
  end


# Property-based testing
# Functions for property-based testing:
  def neutral_elem(t_size) do
    t = AVLDict.from_list(Enum.map(1..t_size, fn _ -> {:rand.uniform(50), 0} end))
    r = AVLDict.merge(t, @null_node)
    # r = t + 0 = t
    assert AVLDict.to_list(t) == AVLDict.to_list(r)
    r2 = AVLDict.merge(@null_node, t)
    # r2 = 0 + t = t
    assert AVLDict.to_list(t) == AVLDict.to_list(r2)
  end

  def associativity(t1_size, t2_size, t3_size) do
    t1 =
      AVLDict.from_list(Enum.map(1..t1_size, fn _ -> {:rand.uniform(50), :rand.uniform(100)} end))

    t2 =
      AVLDict.from_list(Enum.map(1..t2_size, fn _ -> {:rand.uniform(50), :rand.uniform(100)} end))

    t3 =
      AVLDict.from_list(Enum.map(1..t3_size, fn _ -> {:rand.uniform(50), :rand.uniform(100)} end))

    # r1 = t1 + (t2 + t3)
    r1 = AVLDict.merge(t1, AVLDict.merge(t2, t3))
    # r2 = (t1 + t2) + t3
    r2 = AVLDict.merge(AVLDict.merge(t1, t2), t3)

    # r1 == r2
    assert AVLDict.to_list(r1) == AVLDict.to_list(r2)
  end

  # Testing the neutral element property of a monoid by running the neutral_elem function 5000 times
  test "Neutral Element" do
    Enum.map(1..5_000, fn _ -> neutral_elem(:rand.uniform(1000) - 1) end)
  end

# Associativity of the multiplication operation - merging of trees

  # Testing the associativity property of the tree merging (addition) operation in a monoid by running
  # associativity functions 5000 times. Testing on AVL trees with a small number of nodes (<10)
  test "Small Monoid Test" do
    Enum.map(1..5_000, fn _ ->
      associativity(:rand.uniform(10) - 1, :rand.uniform(10) - 1, :rand.uniform(10) - 1)
    end)
  end

# Testing the associativity property of the tree merging (addition) operation in a monoid by running
  # associativity functions 5000 times. Testing on AVL trees with an average number of nodes (<100)
  test "Medium Monoid Test" do
    Enum.map(1..5_000, fn _ ->
      associativity(:rand.uniform(100) - 1, :rand.uniform(100) - 1, :rand.uniform(100) - 1)
    end)
  end

# Testing the associativity property of the tree merging (addition) operation in a monoid by running
  # associativity functions 5_000 times. Testing on AVL trees with a large number of nodes (<1000)
  test "Big Monoid Test" do
    Enum.map(1..5_000, fn _ ->
      associativity(:rand.uniform(1000) - 1, :rand.uniform(1000) - 1, :rand.uniform(1000) - 1)
    end)
  end
end
