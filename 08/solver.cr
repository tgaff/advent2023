require "./node"

record Steps, list : Array(Char), total : Int32

class Solver
  @step_count = 0
  getter :step_count
  @current_node : Node
  getter :current_node

  def initialize(inputs)
    step_list = inputs.shift.chars
    @steps = Steps.new(step_list, step_list.size)

    puts "got step_list #{@steps.list} of size #{@steps.total}"

    # create each node and store it in satchel for lookup later
    @satchel = {} of String => Node
    inputs.shift # skip empty line
    inputs.each do |input|
      node = Node.new(input)
      @satchel[node.name] = node
    end

    @current_node = @satchel["AAA"]
  end

  def current_step
    step_index = @step_count % @steps.total
    @steps.list[step_index]
  end

  def increment_step
    @step_count += 1
  end

  def run
    until current_node.name == "ZZZ"
      if current_step == 'L'
        go_left
      elsif current_step == 'R'
        go_right
      else
        raise "Impossible step #{current_step} @#{@step_count}"
      end

    increment_step
    end

    return @step_count
  end

  def go_left
    next_node = @satchel[@current_node.left]
    raise "this node has no left #{@current_node}" if next_node.nil?

    @current_node = next_node
  end

  def go_right
    next_node = @satchel[@current_node.right]
    raise "this node has no right #{@current_node}" if next_node.nil?

    @current_node = next_node
  end
end
