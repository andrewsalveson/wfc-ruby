require(File.expand_path('./cell.rb', File.dirname(__FILE__)))

describe("cell operations", lambda {
  describe("rotateCell", lambda {
    it("rotates a cell by 1 by default", lambda {
      a = "A"
      c = cell(a)

      # function under test
      result = rotateCell(c)

      assertEquals(result, [a,1,false,false])
    })
    it("rotates a cell twice", lambda {
      a = "A"
      c = cell(a)

      # function under test
      d = rotateCell(c)
      e = rotateCell(d)

      assertEquals(e, [a,2,false,false])
    })
    it("rotates a cell three times", lambda {
      a = "A"
      c = cell(a)

      # function under test
      d = rotateCell(c)
      e = rotateCell(d)
      f = rotateCell(e)

      assertEquals(f, [a, 3,false,false])
    })
    it("allows for negative rotation", lambda {
      a = "A"
      c = cell(a)

      # function under test
      result = rotateCell(c, -1)

      assertEquals(result, [a, 3,false,false])
    })
  })
  describe("flipCell", lambda {
    a = "A"
    describe("over X axis", lambda {
      it("flips a cell's X value", lambda {
        c = cell(a)
    
        # function under test
        result = flipCell(c, X_FLIP)
    
        assertEquals(result, [a,2,true,false])
      })
      it("flips cell aligned to Y axis", lambda {
        c = cell(a)
        d = rotateCell(c)
  
        # function under test
        result = flipCell(d, X_FLIP)
  
        assertEquals(result, [a,1,true,false])
      })
    })
    describe("over Y axis", lambda {
      it("flips a cell's Y value", lambda {
        c = cell(a)
        d = rotateCell(c)

        # function under test
        result = flipCell(d, Y_FLIP)
  
        assertEquals(result, [a,3,false,true])
      })
      it("flips cell aligned to X axis", lambda {
        c = cell(a)

        # function under test
        result = flipCell(c, Y_FLIP)

        assertEquals(result, [a,0,false,true])
      })
    })
  })
  describe("flipCellDiagXY", lambda {
    [
      [[1,0,false,false],[1,1,true,false]],
      [[1,1,false,false],[1,0,true,false]],
      [[1,2,false,false],[1,3,true,false]],
      [[1,3,false,false],[1,2,true,false]]
    ].each do |testData|
      input,expected = testData
      it("flips #{input} to #{expected}", lambda {
        # function under test
        result = flipCellDiagXY(input)

        assertEquals(result, expected)
      })
    end
  })
  describe("flipCellDiagYX", lambda {
    [
      [[1,0,false,false],[1,3,false,true]],
      [[1,1,false,false],[1,2,false,true]],
      [[1,2,false,false],[1,1,false,true]],
      [[1,3,false,false],[1,0,false,true]],
    ].each do |testData|
      input,expected = testData
      it("flipx #{input} to #{expected}", lambda {
        # function under test
        result = flipCellDiagYX(input)

        assertEquals(result, expected)
      })
    end
  })
})
