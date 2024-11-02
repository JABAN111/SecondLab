## Выполнил

- ФИО:`Нягин Михаил Алексеевич`
- ISU_ID:`368601`
- Группа:`P3313`
- Вариант `avl-dict`

## Участвующие структуры: 

```elixir
defmodule SecondLab do
  defmodule Node do
    @moduledoc """
    The node of AVL tree. The structure consists of a key, a value, the height of the tree, pointers to the left and right subtrees
    """
    defstruct [:key, :value, :height, :left, :right]
  end

  defmodule AVLDict do
    @moduledoc """
    The interface is a dictionary that uses the data structure - AVL-tree
    """
    @null_node %Node{key: nil, value: nil, left: nil, right: nil, height: 0}

    def height(@null_node), do: 0

    def height(%Node{left: left, right: right}) do
      max(height(left), height(right)) + 1
    end
    ...
```


## Property based testing 
```elixir
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
```

## Результаты тестов

```bash
jaba in ~/Documents/life/ITMO/FP/secondLab/SecondLab on main λ mix test
Running ExUnit with seed: 576585, max_cases: 20

...................
Finished in 26.9 seconds (0.00s async, 26.9s sync)
19 tests, 0 failures
```

# Вывод
Я познакомился с тестированием в рамках функционального языка Elixir, настроил Linter и узнал, кто это такой ваш property based testing