XPYP =  [ 1, 1, 0]
XPYM =  [ 1,-1, 0]
XMYP =  [-1, 1, 0]
XMYM =  [-1,-1, 0]

XPLUS = [ 1, 0, 0]
XMIN =  [-1, 0, 0]

YPLUS = [ 0, 1, 0]
YMIN =  [ 0,-1, 0]

ZPLUS = [ 0, 0, 1]
ZMIN =  [ 0, 0,-1]

NEIGHBORHOOD = [
  XPLUS, XMIN,
  YPLUS, YMIN,
  ZPLUS, ZMIN
]

NEIGHBORHOOD_DIAG = NEIGHBORHOOD + [
  XPYP, XPYM, XMYP, XMYM
]

NEIGHBOR_MATCH = {
  XPYP =>  [[ 0, 0, 0],[-1,-1, 0]],
  XPYM =>  [[ 0,-1, 0],[-1, 0, 0]],
  XMYP =>  [[-1, 0, 0],[ 0,-1, 0]],
  XMYM =>  [[-1,-1, 0],[ 0, 0, 0]],

  XPLUS => [[ 0, 0, 0],[-1, 0, 0]],
  YPLUS => [[ 0, 0, 0],[ 0,-1, 0]],
  ZPLUS => [[ 0, 0, 0],[ 0, 0,-1]],

  XMIN =>  [[-1, 0, 0],[ 0, 0, 0]],
  YMIN =>  [[ 0,-1, 0],[ 0, 0, 0]],
  ZMIN =>  [[ 0, 0,-1],[ 0, 0, 0]]
}

ERR_GRID_SQUARE = 'grid is not square'
