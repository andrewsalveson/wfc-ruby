
# create a cell with rotation 0
def cell(val)
  [val,0,false,false]
end

def isCell(val)
  val.kind_of?(Array) and not val[1].nil?
end

# rotate a cell if it has expected cell structure
# otherwise return input value
def rotateCell(cell,by=1)
  return cell if not isCell(cell)
  # puts "rotating #{cell} by #{by}"
  val,rot,x,y = cell
  rot = (rot+by) % 4
  [val, rot,x,y]
end

X_FLIP = [0,2]
Y_FLIP = [1,3]

# flipping the cell will change the orientation
# by 180 degrees
def flipCell(cell,dir)
  return cell if not isCell(cell)
  # puts "flipping #{cell} in #{dir == X_FLIP ? 'x' : 'y'}"
  val,rot,xflip,yflip = cell
  # puts "#{val} #{rot} #{xflip} #{yflip}"
  xflip = !xflip if dir == X_FLIP
  yflip = !yflip if dir == Y_FLIP
  rot = (rot+2) % 4 if not dir.index(rot).nil?
  # puts "final: #{rot}"
  [val, rot, xflip, yflip]
end

def flipCellDiagXY(cell)
  return cell if not isCell(cell)
  val,rot,x,y = cell
  if rot == 1 then
    rot = 0
  elsif rot == 2 then
    rot = 3
  elsif rot == 3 then
    rot = 2
  elsif rot == 0 then
    rot = 1
  end
  [val,rot,!x,y]
end

def flipCellDiagYX(cell)
  return cell if not isCell(cell)
  val,rot,x,y = cell
  if rot == 1 then
    rot = 2
  elsif rot == 2 then
    rot = 1
  elsif rot == 3 then
    rot = 0
  elsif rot == 0 then
    rot = 3
  end
  [val,rot,x,!y]
end
