require(File.expand_path('./wave.rb', File.dirname(__FILE__)))
require(File.expand_path('./util.rb', File.dirname(__FILE__)))

describe("waveNeighborhood", lambda {
  it("always returns 6 values even in empty wave", lambda {
    # function under test
    results = waveNeighborhood({}, [1,1,1])

    assertEquals(results, [nil,nil,nil,nil,nil,nil])
  })
  it("returns real neighbors in populated wave", lambda {
    wave = {
      [1,1,1] => :x,
      [2,1,1] => :a,
      [0,1,1] => :b,
      [1,2,1] => :c,
      [1,0,1] => :d,
      [1,1,2] => :e,
      [1,1,0] => :f
    }

    # function under test
    results = waveNeighborhood(wave, [1,1,1])

    assertEquals(results, [:a,:b,:c,:d,:e,:f])
  })
})

describe("printZ", lambda {
  it("prints a wave", lambda {
    conf = Config.new
    patterns = {
      [[[cell(:a)],[cell(:b)]],[[cell(:c)],[cell(:d)]]] => 1.0
    }
    wave = makeWave(conf,patterns)

    [
      [0,0,0],
      [1,1,0],
      [2,2,0],
      [3,3,0],
      [4,4,0]
    ].each{|addr| wave[addr].resolve(cell(:x))}

    printZ(conf,wave)
  })
})

describe("Wavelet", lambda {
  dims = [2,2,1]
  p1 = [[[[:a]],[[:b]]],[[[:a]],[[:b]]]]
  p2 = [[[[:b]],[[:a]]],[[[:b]],[[:a]]]]

  p1prob = 0.75
  p2prob = 0.25

  patterns = {
    p1 => p1prob,
    p2 => p2prob
  }
  it("initializes as UNDECIDED", lambda {
    wavelet = Wavelet.new(dims,patterns)

    assertEquals(wavelet.state,Wavelet::UNDECIDED)
  })
  describe("allowed", lambda {
    it("contains all allowed patterns", lambda {
      wavelet = Wavelet.new(dims,patterns)

      # function under test
      results = wavelet.allowed

      assertEquals(results, [p1,p2])
    })
  })
  describe("ban", lambda {
    it("removes patterns from allowed", lambda {
      wavelet = Wavelet.new(dims,patterns)

      assert { wavelet.allowed.size == 2 }

      # function under test
      wavelet.ban(p1)

      assert{ wavelet.allowed.size == 1 }
    })
    it("does not ban patterns that do not exist", lambda {
      wavelet = Wavelet.new(dims,patterns)

      # function under test
      wavelet.ban([[[[:d]],[:b]],[[:a],[:c]]])

      assert{ wavelet.allowed.size == 2 }
    })
    it("throws if all patterns are banned", lambda {
      wavelet = Wavelet.new(dims,patterns)

      wavelet.ban(p1)

      assertEquals(wavelet.allowed.size,1)
  
      threw = false
      begin
        wavelet.ban(p2)
      rescue
        threw = true
      end
      assertEquals(threw, true)
    })
  })
  describe("collapse", lambda {
    it("collapses to DECIDED with 0 entropy", lambda {
      wavelet = Wavelet.new(dims,patterns)

      wavelet.collapse

      assertEquals(wavelet.state, Wavelet::DECIDED)
      assertEquals(wavelet.entropy,0)
    })
    it("resolves to allowed pattern", lambda {
      wavelet = Wavelet.new(dims,patterns)

      wavelet.ban(p1)

      # function under test
      wavelet.collapse

      assertEquals(wavelet.resolved,p2)
    })
    it("has 1 allowed pattern after collapse", lambda {
      p3 = [[[[:b]],[[:b]]],[[[:c]],[[:c]]]]
      p4 = [[[[:c]],[[:c]]],[[[:d]],[[:d]]]]
      extPatterns = {
        p1 => 0.25,
        p2 => 0.25,
        p3 => 0.25,
        p4 => 0.25
      }
      wavelet = Wavelet.new(dims,extPatterns)

      assertEquals(wavelet.allowed.size,4)

      # function under test
      wavelet.collapse

      assertEquals(wavelet.allowed.size,1)
    }) 
  })
  describe("select", lambda {    
    sampleSize = 1000    
    threshold = 0.05

    it("selects patterns at roughly the supplied probability", lambda {
      wavelet = Wavelet.new(dims,patterns)

      results = {
        :p1 => 0,
        :p2 => 0
      }

      # function under test
      sampleSize.times{ results[wavelet.select == p1 ? :p1 : :p2 ] += 1 }

      p1diff = (results[:p1] / sampleSize.to_f - p1prob).abs
      p2diff = (results[:p2] / sampleSize.to_f - p2prob).abs

      assert{ p1diff < threshold}
      assert{ p2diff < threshold}
    })
    it("does not select patterns that have been banned", lambda {
      wavelet = Wavelet.new(dims,patterns)

      results = {
        :p1 => 0,
        :p2 => 0
      }

      wavelet.ban(p1)

      # function under test
      sampleSize.times{
        selected = wavelet.select
        results[selected == p1 ? :p1 : :p2] += 1
      }

      assert { results[:p2] == sampleSize }
    })
  })
})
