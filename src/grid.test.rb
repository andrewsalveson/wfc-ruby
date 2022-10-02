require(File.expand_path('./grid.rb', File.dirname(__FILE__)))

describe("wrap", lambda {
  conf = Config.new
  conf.wrap = [true,true,true]
  [
    [[2,2,2],[0,0,2],[0,0,0]],
    [[4,4,4],[1,2,3],[1,2,3]],
    [[4,4,4],[1,2,-1],[1,2,3]],
    [[4,4,4],[1,2,5],[1,2,1]],
    [[3,3,1],[0,-1,0],[0,2,0]]
  ].each do |testRow|
    dims,coord,expected = testRow
    it("wraps coordinates #{coord} in #{dims} to #{expected}", lambda {
      # function under test
      result = wrap(conf,dims,coord)

      assertEquals(result, expected)
    })
  end
})

describe("gridDims", lambda {
  it("calculates the dimensions of a grid", lambda {
    # function under test
    x,y,z = gridDims([[[1]]])
    assert{x == 1}
    assert{y == 1}
    assert{z == 1}
  })
  it("calculates the dimensions of a multidimensional grid", lambda {
    # function under test
    x,y,z = gridDims([
      [[1],[1]],
      [[1],[1]],
      [[1],[1]]
    ])
    assertEquals(x,3)
    assertEquals(y,2)
    assertEquals(z,1)
  })
})

describe("getValue", lambda {
  a = cell("a")
  b = cell("b")
  c = cell("c")
  grid = [
    [[a],[a],[a]],
    [[a],[b],[a]],
    [[c],[c],[c]]
  ]
  it("gets a simple value", lambda {
    conf = Config.new

    # function under test
    result = getValue(conf,grid,[1,1,0])

    assertEquals(result, b)
  })
  it("gets a wrapped value", lambda {
    # configuration default value is that
    # wrapping is true for all axes
    conf = Config.new
    conf.wrap = [true,true,true]

    # function under test
    result = getValue(conf,grid,[-1,-1,-1])

    assertEquals(result, c)
  })
  it("gets nil if no wrapping and out of bounds", lambda {
    conf = Config.new
    conf.wrap = [false,false,false]

    # function under test
    result = getValue(conf,grid,[-1,-1,-1])

    assertEquals(result, nil)
  })
})
