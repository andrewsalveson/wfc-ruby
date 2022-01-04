
### from https://leetcode.com/problems/kth-largest-element-in-a-stream/discuss/486436/ruby-minheap-solution
class KthLargest
  :type k: Integer
  :type nums: Integer[]
  def initialize(k, nums)
    @k = k
    @minHeap = MinHeap.new
    nums.each do |n|
      @minHeap << n
      @minHeap.pop if @minHeap.length - 1 >= @k
    end
  end  
  :type val: Integer
  :rtype: Integer
  def add(val)
    if @minHeap.length - 1 <= @k || val > @minHeap.peek
      @minHeap << val
    end
    
    @minHeap.pop if @minHeap.length - 1 >= @k
    @minHeap.peek()
  end
end
  
class MinHeap
  # Implement a MinHeap using an array
  def initialize
    # Initialize arr with nil as first element
    # This dummy element makes it where first real element is at index 1
    # You can now divide i / 2 to find an element's parent
    # Elements' children are at i * 2 && (i * 2) + 1
    @elements = [nil]
  end
      
  def min
    @elements[1..-1].min
  end
      
  def <<(element)
    # push item onto end (bottom) of heap
    @elements.push(element)
    # then bubble it up until it's in the right spot
    bubble_up(@elements.length - 1)
  end
      
  def pop
    # swap the first and last elements
    @elements[1], @elements[@elements.length - 1] = @elements[@elements.length - 1], @elements[1]
    # Min element is now at end of arr (bottom of heap)
    min = @elements.pop
    # Now bubble the top element (previously the bottom element) down until it's in the correct spot
    bubble_down(1)
    # return the min element
    min
  end
      
  def length
    @elements.length - 1
  end
  
  def peek
    @elements[1]
  end
  
  def print
    @elements
  end
  
  private
      
  def bubble_up(index)
    parent_i = index / 2
    # Done if you reach top element or parent is already smaller than child
    return if index <= 1 || @elements[parent_i] <= @elements[index]
    
    # Otherwise, swap parent & child, then continue bubbling
    @elements[parent_i], @elements[index] = @elements[index], @elements[parent_i]
    
    bubble_up(parent_i)
  end
      
  def bubble_down(index)
    child_i = index * 2
    return if child_i > @elements.size - 1
    
    # get largest child
    not_last = child_i < @elements.size - 1
    left = @elements[child_i]
    right = @elements[child_i + 1]
    child_i += 1 if not_last && right < left
    
    # stop if parent element is already less than children
    return if @elements[index] <= @elements[child_i]
    
    # otherwise, swap and continue
    @elements[index], @elements[child_i] = @elements[child_i], @elements[index]
    bubble_down(child_i)
  end
end
