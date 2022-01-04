require_relative './cell.rb'

# flip a 2-dimensional grid along the X=Y diagonal
def flipDiagXY(grid)
  d,ny = gridDims(grid)
  raise GRIDMATRIX_SQUARE if d != ny

  temp = Array.new(d){Array.new(d)}
  # flip diagonally
  d.times do |x|
    d.times do |y|
      temp[x][y] = (grid[y].nil? or grid[y][x].nil?) ? nil : grid[y][x].map{|c|flipCellDiagXY(c)}
    end
  end
  temp
end

def flipDiagYX(grid)
  d,ny = gridDims(grid)
  raise GRIDMATRIX_SQUARE if d != ny

  temp = Array.new(d){Array.new(d)}
  # flip diagonally
  d.times do |x|
    d.times do |y|
      xi = d - y - 1
      yi = d - x - 1
      temp[x][y] = (grid[xi].nil? or grid[xi][yi].nil?) ? nil : grid[xi][yi].map{|c|flipCellDiagYX(c)}
    end
  end
  temp
end

# rotate a 2-dimensional grid clockwise
def rotateXY(grid)
  d,ny = gridDims(grid)
  raisGRIDMATRIX_SQUARE if d != ny

  flipped = flipDiagYX(grid)

  reflectY(flipped)
end

def reflectY(grid)
  d,ny = gridDims(grid)
  raisGRIDMATRIX_SQUARE if d != ny

  flipped = Array.new(d){Array.new(d)}
  # flip vertically
  d.times do |x|
    (d / 2).floor.times do |y|
      flipped[x][y] = grid[x][d - y - 1].map{|c|flipCell(c, X_FLIP)}
      flipped[x][d - y - 1] = grid[x][y].map{|c|flipCell(c, X_FLIP)}
    end
  end
  flipped
end

def reflectX(grid)
  d,ny = gridDims(grid)
  raisGRIDMATRIX_SQUARE if d != ny

  flipped = Array.new(d){Array.new(d)}
  # flip vertically
  d.times do |x|
    (d / 2).floor.times do |y|
      flipped[x][y] = grid[x][d - y - 1].map{|c|flipCell(c, Y_FLIP)}
      flipped[x][d - y - 1] = grid[x][y].map{|c|flipCell(c, Y_FLIP)}
    end
  end
  flipped
end
