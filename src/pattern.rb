require(File.expand_path('./cell.rb', File.dirname(__FILE__)))

def printPattern(pattern)
  nx = pattern.size
  ny = nz = 0
  pattern.each do |row|
    ny = row.size if row.size > ny
    row.each do |col|
      nz =col.size if col.size > nz
    end
  end

  out = Array.new(nx){Array.new(nx * nz){Array.new(ny)}}
  pattern.each_with_index do |row,x|
    row.each_with_index do |col,y|
      col.each_with_index do |lvl,z|
        outRow = [x,z]
        idx = ((x / nx) * nx) + z
        out[x][idx][y] = "#{lvl.is_a?(Array) ? lvl.join('|') : lvl}".rjust(8," ")
      end
    end
  end
  puts ""
  puts out.map{|xrow| xrow.map{|row| row.join(" ")}.join("\n")}
  puts ""
end

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
