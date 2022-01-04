require_relative './constants.rb'
require_relative './util.rb'

# wrap will wrap out-of-bounds coordinates within
# given grid dimensions in the x,y, and z direction
def wrap(conf,gridDims, cellCoords)
  settings = conf.wrap
  wrapped = Array.new(cellCoords.size)
  # ruby 1.5 doesn't have map with index :(
  cellCoords.each_with_index do |c,i|
    if not settings[i] then 
      wrapped[i] = c
    else
      wrapped[i] = c % gridDims[i]
    end
  end
  wrapped
end

# get 3-dimensional dims
def gridDims(input)
  x = input.size
  y = input[0].size
  z = input[0][0]
  [x,y, z.kind_of?(Array) ? z.size : 1]
end

def getValue(conf,grid,coords)
  dims = gridDims(grid)
  x,y,z = wrap(conf,dims,coords)
  gx,gy,gz = dims
  return nil if x > gx || x < 0
  return nil if y > gy || y < 0
  return nil if z > gz || z < 0
  grid[x][y][z]
end
