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

    # Node balancing - when the height difference of the left and right subtrees is not equal to 2 - we return unchanged
    def balance(
          %Node{left: %Node{height: left_height}, right: %Node{height: right_height}} = node
        )
        when abs(left_height - right_height) <= 1 do
      node
    end

    # Node balancing - perform a right turn around the node
    def balance(
          %Node{
            left:
              %Node{
                left: left_left,
                right: left_right
              } = left,
            right: %Node{height: right_height}
          } = node
        )
        when left_left.height - right_height == 1 do
      new_right_height = max(right_height, left_right.height) + 1

      %Node{
        left
        | height: max(new_right_height, left_right.height) + 1,
          right: %Node{node | height: new_right_height, left: left_right},
          left: left_left
      }
    end

    # Node balancing - perform a left turn around the node
    def balance(
          %Node{
            left: %Node{height: left_height},
            right:
              %Node{
                right: right_right,
                left: right_left
              } = right
          } = node
        )
        when right_right.height - left_height == 1 do
      new_left_height = max(left_height, right_left.height) + 1

      %Node{
        right
        | height: max(new_left_height, right_left.height) + 1,
          left: %Node{node | height: new_left_height, right: right_left},
          right: right_right
      }
    end

    # Node balancing - big right turn (first left turn around left and then right turn around node)
    def balance(
          %Node{
            left:
              %Node{
                right:
                  %Node{left: left_right_left, right: left_right_right} =
                    left_right,
                left: left_left
              } = left,
            right: %Node{height: right_height}
          } = node
        )
        when left_right.height - right_height == 1 do
      %Node{
        left_right
        | height: left_left.height + 2,
          left: %Node{
            left
            | height: left_left.height + 1,
              left: left_left,
              right: left_right_left
          },
          right: %Node{node | height: left_left.height + 1, left: left_right_right}
      }
    end

    # Node balancing - big left turn (first right turn around right and then left turn around node)
    def balance(
          %Node{
            right:
              %Node{
                left:
                  %Node{left: right_left_left, right: right_left_right} =
                    right_left,
                right: right_right
              } = right,
            left: %Node{height: left_height}
          } = node
        )
        when right_left.height - left_height == 1 do
      %Node{
        right_left
        | height: right_right.height + 2,
          left: %Node{node | height: right_right.height + 1, right: right_left_left},
          right: %Node{
            right
            | height: right_right.height + 1,
              left: right_left_right,
              right: right_right
          }
      }
    end

    # Inserting the node value by key into the AVL tree - if the input node is empty, then just
    # creating a new node without subtrees
    def insert(@null_node, key, value),
      do: %Node{key: key, value: value, height: 1, left: @null_node, right: @null_node}

    # Inserting the node value by key into the AVL tree - if the key of the input node matches the input key,
    # then we update the value in the input node
    def insert(node, key, value) when node.key == key,
      do: %Node{node | value: value}

    def insert(%Node{left: left} = node, key, value) when node.key > key do
      new_left = insert(left, key, value)
      balance(%Node{node | left: new_left, height: max(height(new_left) + 1, node.height)})
    end

    def insert(%Node{right: right} = node, key, value) when node.key < key do
      new_right = insert(right, key, value)
      balance(%Node{node | right: new_right, height: max(height(new_right) + 1, node.height)})
    end

    def find(_key, @null_node), do: :not_found

    def find(key, %Node{key: key, value: value}), do: {key, value}

    def find(key, %Node{key: node_key, left: left}) when node_key > key, do: find(key, left)

    def find(key, %Node{key: node_key, right: right}) when node_key < key, do: find(key, right)

    # find_min function - returns tuple: {minimum element, new left node, flag}
    # Searching for a node with a minimum key from the AVL tree to delete it - when the left subtree is empty,
    # the node with the minimum key is the current node, delete and replace it with the right subtree
    def find_min(%Node{key: key, value: value, height: _, left: @null_node, right: right}) do
      {%Node{key: key, value: value, height: nil, left: nil, right: nil}, right, true}
    end

    # Searching for a node with the minimum key from the AVL tree to delete it - when the left subtree is empty,
    # the node with the minimum key is in the left subtree
    def find_min(%Node{key: key, value: value, height: _, left: left, right: @null_node}) do
      {left, %Node{key: key, value: value, height: 1, left: @null_node, right: @null_node}, true}
    end

    # Searching for a node with the minimum key from the AVL tree to delete it - when both subtree are not empty,
    # the node with the minimum key is located in the left subtree, recursively calling find_min for left
    def find_min(%Node{
          key: key,
          value: value,
          height: _,
          left: left,
          right:
            %Node{
              left: left_r,
              right: right_r
            } = right
        }) do
      {min, new_left, is_last_call} = find_min(left)

      # If is_last_call is true and both subtree (new left and right) are empty (height is 2), then
      # the node with the minimum key and the updated node with height 2 are returned

      case {is_last_call, %Node{height: height_new_left} = new_left, right_r, right.height} do
        {true, @null_node, @null_node, 2} ->
          {min,
           %Node{
             left_r
             | height: 2,
               left: %Node{
                 key: key,
                 value: value,
                 height: 1,
                 left: @null_node,
                 right: @null_node
               },
               right: %Node{
                 key: right.key,
                 value: right.value,
                 height: 1,
                 left: @null_node,
                 right: @null_node
               }
           }, false}

        # Если is_last_call равно true, но только левое поддерево пусто, то возвращается узел с минимальным ключом
        # и обновленный узел с правым поддеревом
        {true, @null_node, _, _} ->
          {min,
           %Node{
             key: right.key,
             value: right.value,
             height: max(left_r.height + 1, right_r.height) + 1,
             left: %Node{
               key: key,
               value: value,
               left: @null_node,
               right: left_r,
               height: left_r.height + 1
             },
             right: right_r
           }, false}

        # Otherwise, the node with the minimum key and the balanced node with the updated height are returned
        _ ->
          {min,
           balance(%Node{
             key: key,
             value: value,
             height: max(height_new_left + 1, right.height) + 1,
             left: new_left,
             right: right
           }), false}
      end
    end

    # Функция remove возвращает дерево AVLDict (а точнее корневой узел дерева Node) после удаления элемента
    # Удаление узлов из AVL-дерева - если дерево пустое, то ключ не найден, возвращается атом :not_found
    def remove(_key, @null_node), do: :not_found

    # Удаление узлов из AVL-дерева - если узел с указанным ключом найден и не имеет ни левого, ни правого поддеревьев,
    # то узел просто удаляется, и возвращается @null_node
    def remove(key, %Node{
          key: key,
          value: _value,
          height: _,
          left: @null_node,
          right: @null_node
        }),
        do: @null_node

    # Removing nodes from the AVL tree - if a node with the specified key is found and has only the left subtree, then
    # the left subtree is returned as the new node value
    def remove(key, %Node{key: key, value: _value, height: _, left: left, right: @null_node}),
      do: left

    # Deleting nodes from the AVL tree - if a node with the specified key is found and has only the right subtree, then
    # the right subtree is returned as the new node value
    def remove(key, %Node{key: key, value: _value, height: _, left: @null_node, right: right}),
      do: right

    # Removing nodes from the AVL tree - if a node with the specified key is found and has both subtrees, then it is used
    # the node with the minimum key from the right subtree (obtained via find_min)
    def remove(key, %Node{
          key: key,
          value: _value,
          height: _,
          left: left,
          right: right
        }) do
      {min, new_right, _} = find_min(right)

      case min do
        @null_node ->
          @null_node

        %Node{key: min_key, value: min_value} ->
          balance(%Node{
            key: min_key,
            value: min_value,
            left: left,
            right: new_right,
            height: max(left.height, new_right.height) + 1
          })
      end
    end

    # Deleting nodes from the AVL tree - if the specified key is less than the key of the current node, then
    # remove is called recursively for the left subtree, a new left subtree is found
    def remove(target_key, %Node{
          key: key,
          value: value,
          height: _,
          left: left,
          right: right
        })
        when target_key < key do
      new_left = remove(target_key, left)

      case {new_left, right} do
        {:not_found, _} ->
          :not_found

        {@null_node, @null_node} ->
          %Node{key: key, value: value, height: 1, left: @null_node, right: @null_node}

        {%Node{height: height_new_left}, _} ->
          balance(%Node{
            key: key,
            value: value,
            height: max(height_new_left, right.height) + 1,
            left: new_left,
            right: right
          })
      end
    end

    # Deleting nodes from the AVL tree - if the specified key is greater than the key of the current node, then
    # remove is called recursively for the right subtree, a new right subtree is found
    def remove(target_key, %Node{
          key: key,
          value: value,
          height: _,
          left: left,
          right: right
        })
        when target_key > key do
      new_right = remove(target_key, right)

      case {left, new_right} do
        {_, :not_found} ->
          :not_found

        {@null_node, @null_node} ->
          %Node{key: key, value: value, height: 1, left: @null_node, right: @null_node}

        {_, %Node{height: height_new_right}} ->
          balance(%Node{
            key: key,
            value: value,
            height: max(height_new_right, left.height) + 1,
            left: left,
            right: new_right
          })
      end
    end

    # The wrap_remove function is a wrapper for calling remove, checking the result of deletion.
    def wrap_remove(key, tree) do
      case remove(key, tree) do
        :not_found -> tree
        {_, new_tree, _} -> new_tree
        new_tree -> new_tree
      end
    end

    # Converting a tree to a list of pairs - if the tree is empty, then an empty list is returned
    def to_list(@null_node), do: []

    # Converting a tree to a list of pairs - the function processes the left subtree, then adds the current node
    # (key and value) and finally handles the right subtree. The result of the recursive transformation of the AVL tree
    # to the list of pairs {key, value} - a list of all nodes of the tree in the order of traversal
    def to_list(%Node{key: key, value: value, left: left, right: right}) do
      to_list(left) ++ [{key, value}] ++ to_list(right)
    end

    # Creating an AVL tree from a list of {key, value} pairs - the foldl function is used to traverse the list and insert each
    # of an element in the tree using the insert function. The initial value for the accumulator is an empty node
    def from_list(list) do
      :lists.foldl(fn {key, value}, acc -> insert(acc, key, value) end, @null_node, list)
    end

    # Applying (map) the specified func function to each node of the tree - if the input node is empty (the tree is empty),
    # then an empty list is returned
    def map(nil, _), do: []

    # Applying (map) the specified func function to each node of the tree - if the tree is not empty,
    # then map recursively traverses the left subtree, applies the func function to the current node, and then traverses the right one
    # # under the tree. As a result, a list of the results of applying the function to all nodes is returned.
    def map(%Node{key: key, value: value, left: left, right: right}, func) do
      map(left, func) ++ [func.({key, value})] ++ map(right, func)
    end

    # Отображение (map) функции func к каждому узлу дерева с возвращением нового дерева с измененными значениями.
    def map_tree(node, func) do
      from_list(map(node, func))
    end

    # Left convolution of the tree - if the input node is empty (the tree is empty), then the accumulator is returned unchanged.
    def foldl(@null_node, acc, _), do: acc

    # Left convolution of the tree - if the tree is not empty, then first the foldl function traverses the left subtree (foldl(left,..))
    # and applies the func function to the accumulator and the current node (func.(foldl(...),{...}), then it bypasses the right
    # subtree (foldl(right,..)). The result is the final value after applying the function to all nodes.
    def foldl(%Node{key: key, value: value, left: left, right: right}, acc, func) do
      foldl(right, func.(foldl(left, acc, func), {key, value}), func)
    end

    # Right convolution of the tree - if the input node is empty (the tree is empty), then the accumulator is returned unchanged.
    def foldr(@null_node, acc, _), do: acc

    # Right convolution of the tree - if the tree is not empty, then first the foldr function traverses the right subtree (foldl(right,..))
    # and applies the func function to the accumulator and the current node (func.(foldr(...),{...}), then it bypasses the left
    # subtree (foldr(left,..)). The result is the final value after applying the function to all nodes.
    def foldr(%Node{key: key, value: value, left: left, right: right}, acc, func) do
      foldr(left, func.(foldr(right, acc, func), {key, value}), func)
    end

    def filter(@null_node, _), do: []

    # Filtering tree nodes based on a given func function - if the tree is not empty, then
    # the specified func function is called for the current node
    def filter(%Node{key: key, value: value, height: _, left: left, right: right}, func) do
      case func.(key, value) do
        # If the function returns true, the node is added to the result
        true ->
          filter(left, func) ++ [{key, value}] ++ filter(right, func)

        # If the function returns false, the node is skipped
        false ->
          filter(left, func) ++ filter(right, func)
      end
    end

    # Filtering tree nodes based on a given func function with the return of a new tree,
    # containing only nodes satisfying the conditions of the function
    def filter_tree(tree, func), do: from_list(filter(tree, func))

    # Combining 2 AVL trees x and y - the foldl function is used to traverse all nodes of the y tree
    # and insert each node into the x tree using the insert function
    # The result is a new tree containing all nodes from both trees
    def merge(x, y) do
      foldl(y, x, fn acc, {key, value} -> insert(acc, key, value) end)
    end

    # Checking the equality of 2 AVL trees x and y - first, the number of nodes of each tree is calculated and compared.
    # If the lengths of the trees are not equal, the function immediately returns false. If the lengths are equal, it passes through all nodes
    # of the y tree and checks if each node with the same key and value is contained in the x tree. If all nodes match,
    # the function returns true, otherwise it returns false.
    def equal_tree(x, y) do
      lenx = foldl(x, 0, fn acc, _ -> acc + 1 end)
      leny = foldl(y, 0, fn acc, _ -> acc + 1 end)

      case lenx == leny do
        false -> false
        _ -> foldl(y, true, fn acc, {key, value} -> acc and find(key, x) === {key, value} end)
      end
    end
  end
end
