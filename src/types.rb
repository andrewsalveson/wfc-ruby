class Config
  attr_accessor :solve
  attr_accessor :wrap, :threshold, :size, :patternSize, :outputSize, :debug
  # limits
  attr_accessor :stopAfter, :propagationLimit
  # debug placement
  attr_accessor :spacing
  # pattern attrs
  attr_accessor :rotations, :reflections
  # by default, do not wrap in the z direction
  def initialize
    @size = 36
    @wrap = [true,true,false]
    @threshold = 0.01
    @patternSize = [2,2,1]
    @rotations = false
    @reflections = false
    @outputSize = [5,5,1]
    @spacing = [120,120,20]
    @solve = true
    @stopAfter = 1000
    @propagationLimit = 10000
    @debug = false
  end
end
