require_relative './types.rb'
require_relative './grid.rb'

describe("pattern operations", lambda {
  describe("flipDiagXY", lambda {
    it("throws if matrix is not square", lambda {
      assertThrows{ flipDiagXY([[1,2,3]]) }
    })
    it("flips a 1x1 matrix", lambda {
      result = flipDiagXY([
        [[cell(1)]]
      ])

      assertEquals(result, [[[[1,1,true,false]]]])
    })
    it("unflips a flipped 1x1 matrix", lambda {
      result = flipDiagXY(flipDiagXY([[[cell(1)]]]))

      assertEquals(result, [[[cell(1)]]])
    })
    it("flips a matrix diagonally", lambda {
      # function under test
      result = flipDiagXY([
        [[cell(1)],[cell(2)]],
        [[cell(3)],[cell(4)]]
      ])

      # not only flips the matrix, but flips cell
      # rotations as well
      assertEquals(result, [
        [[[1,1,true,false]],[[3,1,true,false]]],
        [[[2,1,true,false]],[[4,1,true,false]]]
      ])
    })
  })
  describe("flipDiagYX", lambda {
    it("flips a 1x1 matrix", lambda {
      result = flipDiagYX([
        [[cell(1)]]
      ])

      assertEquals(result, [[[[1,3,false,true]]]])
    })
    it("flips a matrix diagonally", lambda {
      # function under test
      result = flipDiagYX([
        [[cell(1)],[cell(2)]],
        [[cell(3)],[cell(4)]]
      ])

      assertEquals(result, [
        [[[4,3,false,true]],[[2,3,false,true]]],
        [[[3,3,false,true]],[[1,3,false,true]]]
      ])
    })
  })
  describe("rotateXY", lambda {
    it("throws if matrix is not square", lambda {
      assertThrows{ rotateXY([[1,2,3]]) }
    })
    it("rotates a 2x2x1 matrix", lambda {
      # function under test
      result = rotateXY([
        [[1],[2]],
        [[3],[4]]
      ])
  
      assertEquals(result, [
        [[2],[4]],
        [[1],[3]]
      ])
    })
    it("rotates a matrix of cells", lambda {
      grid = [
        [[cell(1)],[cell(2)]],
        [[cell(3)],[cell(4)]]
      ]

      # function under test
      result = rotateXY(grid)

      assertEquals(result, [
        [[[2,3,true,true]],
         [[4,3,true,true]]],
        [[[1,3,true,true]],
         [[3,3,true,true]]]
      ])
    })
    it("rotates from 90 degrees to 180", lambda {
      grid = [
        [[[:a,1,false,false]],
         [[:b,1,false,false]]],
        [[[:c,1,false,false]],
         [[:d,1,false,false]]]
      ]

      # function under test
      result = rotateXY(grid)

      assertEquals(result, [
        [[[:b,0,true,true,]],
         [[:d,0,true,true,]]],
        [[[:a,0,true,true,]],
         [[:c,0,true,true,]]]
      ])
    })
    it("is at 180 degrees when rotated twice", lambda {

      grid = [
        [[cell(:a)],[cell(:b)]],
        [[cell(:c)],[cell(:d)]]
      ]

      # function under test
      r90 = rotateXY(grid)
      r180 = rotateXY(r90)

      assertEquals(r180, [
        [[[:d,2,false,false]],
         [[:c,2,false,false]]],
        [[[:b,2,false,false]],
         [[:a,2,false,false]]]
      ])
    })
    it("produces input when rotated 4 times", lambda {
      grid =[
        [[cell(1)],[cell(2)]],
        [[cell(3)],[cell(4)]]
      ]

      # function under test
      a = rotateXY(grid)
      b = rotateXY(a)
      c = rotateXY(b)
      d = rotateXY(c)

      assertEquals(grid,d)
    })
  })
})
