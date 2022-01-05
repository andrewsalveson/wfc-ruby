require(File.expand_path('./util.rb', File.dirname(__FILE__)))
require(File.expand_path('./wave.rb', File.dirname(__FILE__)))

describe("patterns", lambda {
  describe("2-d pattern in a 2-d grid", lambda {
    # z values
    a = cell("A")
    b = cell("B")
    c = cell("C")

    # 3-dimensional grid, z has range 1
    grid = [
      [[a], [a], [a]],
      [[a], [b], [a]],
      [[c], [c], [c]]
    ]

    size = [2,2,1]
    describe("cellPatterns", lambda {
      it("finds pattern for cell in field", lambda {
        conf = Config.new
        conf.patternSize = size

        # function under test
        results = cellPatterns(conf,grid,[1,1,0])

        assertEquals(results, [
          [[[b],[a]],[[a],[a]]]
        ])
      })
      it("finds patterns that require wrapping", lambda {
        conf = Config.new
        conf.patternSize = size

        # function under test
        results = cellPatterns(conf,grid,[0,0,0])

        assertEquals(results, [
          [[[a],[a]],[[c],[c]]],
        ])
      })
      it("finds edge patterns when wrapping is off", lambda {
        conf = Config.new
        conf.patternSize = size
        conf.wrap = [false,false,false]

        # function under test
        results = cellPatterns(conf,grid,[0,0,0])

        assertEquals(results, [
          [[[a],[nil]],[[nil],[nil]]],
        ])
      })
      it("finds all rotations when rotations is on", lambda {
        conf = Config.new
        conf.patternSize = size
        conf.rotations = true

        # function under test
        results = cellPatterns(conf,grid,[1,1,0])

        # results.each_with_index do |pattern, i|
        #   puts "#{i}: #{pattern}"
        # end
        assertEquals(results.size, 4)
      })
      ### reflections is no longer targeted because of the problems
      ### of undecidability in decomposing affine transformations
      ### combinations of rotations and reflections
      # it("finds all reflections when reflections is on", lambda {
      #   conf = Config.new
      #   conf.patternSize = size
      #   conf.reflections = true

      #   # function under test
      #   results = cellPatterns(conf,grid,[1,1,0])

      #   assertEquals(results.size, 4)
      # })
    })
    describe("allPatterns", lambda {
      it("finds all patterns in grid", lambda {
        conf = Config.new
        conf.patternSize = size
        conf.rotations = true

        # function under test
        results = allPatterns(conf,grid)

        # results.entries.each do |pattern, count|
        #   puts "#{count} instances of #{pattern}"
        # end

        assertEquals(results.size, 28)
      })
    })
  })
})
describe("wfc", lambda {
  # it("produces a grid with expected output size", lambda {
  #   conf = Config.new
  #   conf.patternSize = [3,3,3]
  #   conf.outputSize = [3,3,3]

  #   # function under test
  #   wave,patterns = wfc(conf,[[[1]]],lambda {|a,b|})

  #   assert{wave.size == conf.outputSize.reduce(1){|a,v| a*=v}}
  # })
  it("uses callback to report resolutions", lambda {
    conf = Config.new
    conf.solve = true
    conf.patternSize = [2,2,1]
    conf.outputSize = [3,3,3]

    grid = [
      [[cell(:a)],[cell(:b)]],
      [[cell(:c)],[cell(:d)]]
    ]

    inputDims = gridDims(grid)
    patterns = allPatterns(conf,grid)
    patterns = normalizeWeights(patterns)
    wave = makeWave(conf,patterns)

    wave = wfc(conf,wave)

    # printZ(conf,wave)
  })
})
describe("allPatterns", lambda {
  a = [cell(:a)]
  b = [cell(:b)]
  c = [cell(:c)]
  d = [cell(:d)]
  e = [cell(:e)]
  f = [cell(:f)]

  it("finds all patterns in a 2x2 grid", lambda {
    conf = Config.new
    conf.patternSize = [2,2,1]

    grid = [
      [a,b],
      [c,d]
    ]

    # function under test
    results = allPatterns(conf,grid)

    # results.entries.each do |key,value|
    #   puts "#{key}: #{value}"
    # end
    
    expected = {
      [[a,b],[c,d]] => 1,
      [[b,a],[d,c]] => 1,
      [[c,d],[a,b]] => 1,
      [[d,c],[b,a]] => 1
    }

    results.entries.each_with_index do |ent,i|
      key,value = ent
      assertEquals(key,expected.keys[i])
      assertEquals(value,expected.values[i])
    end
  })
  it("finds all patterns in a 2x3 grid", lambda {
    conf = Config.new
    conf.patternSize = [2,2,1]

    grid = [
      [a,b],
      [c,d],
      [e,f]
    ]

    # function under test
    results = allPatterns(conf,grid)

    # results.entries.each do |key,value|
    #   puts "#{key}: #{value}"
    # end

    expected = {
      [[a,b],[e,f]] => 1,
      [[b,a],[f,e]] => 1,
      [[c,d],[a,b]] => 1,
      [[d,c],[b,a]] => 1,
      [[e,f],[c,d]] => 1,
      [[f,e],[d,c]] => 1
    }

    results.entries.each_with_index do |ent,i|
      key,value = ent
      assertEquals(key,expected.keys[i])
      assertEquals(value,expected.values[i])
    end
    # assertEquals(results, expected)
  })
  describe("3x2 grid", lambda {
    conf = Config.new
    conf.patternSize = [2,2,1]

    grid = [
      [a,b,c],
      [d,e,f]
    ]

    it("finds all patterns with different tiles", lambda {  
      # function under test
      results = allPatterns(conf,grid)

      # results.entries.each do |key,value|
      #   puts "#{key}: #{value}"
      # end

      expected = {
        [[a,c],[d,f]] => 1,
        [[b,a],[e,d]] => 1,
        [[c,b],[f,e]] => 1,
        [[d,f],[a,c]] => 1,
        [[e,d],[b,a]] => 1,
        [[f,e],[c,b]] => 1
      }

      results.entries.each_with_index do |ent,i|
        key,value = ent
        assertEquals(key,expected.keys[i])
        assertEquals(value,expected.values[i])
      end
    })
  })
  it("finds one pattern when all tiles are the same", lambda {
    conf = Config.new
    conf.patternSize = [2,2,1]

    grid = [
      [a,a,a,a,a],
      [a,a,a,a,a],
      [a,a,a,a,a],
      [a,a,a,a,a],
      [a,a,a,a,a]
    ]

    # function under test
    results = allPatterns(conf,grid)

    expected = {
      [[a,a],[a,a]] => 25
    }

    results.entries.each_with_index do |ent,i|
      key,value = ent
      assertEquals(key,expected.keys[i])
      assertEquals(value,expected.values[i])
    end
  })
})
describe("patternsMustMatch", lambda {
  dims = [2,2,1]
  p1 = [[[[:a]],[[:b]]],[[[:a]],[[:b]]]]
  p2 = [[[[:b]],[[:a]]],[[[:b]],[[:a]]]]
  p1prob = 0.75
  p2prob = 0.25

  patterns = {
    p1 => p1prob,
    p2 => p2prob
  }
  it("bans patterns that do not match", lambda {
    wavelet = Wavelet.new(dims,patterns)

    # function under test
    # result = wavelet.patternsMustMatch([[:a]],[0,0,0])
    result = patternsMustMatch(wavelet,[[:a]],[0,0,0])

    puts "#{wavelet.allowed.size} remaining"

    assertEquals(result, true)
    assertEquals(wavelet.allowed,[p1])
  })
  it("throws if no patterns remain", lambda {
    wavelet = Wavelet.new(dims,patterns)

    threw = false
    begin
      # function under test
      # wavelet.patternsMustMatch([[:f]],[0,0,0])
      patternsMustMatch(wavelet,[[:f]],[0,0,0])
    rescue
      threw = true
    end
    assertEquals(threw, true)
  })
})
