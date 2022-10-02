require(File.expand_path('./constants.rb', File.dirname(__FILE__)))

def waveNeighborhood(wave,address)
  cx,cy,cz = address
  NEIGHBORHOOD.map do |ndelta|
    dx,dy,dz = ndelta
    ncoords = [cx+dx, cy+dy, cz+dz]
    wave[ncoords]
  end
end

# map of {[x,y,z] => Wavelet}
def makeWave(conf,patterns)
  wave = {}

  x,y,z = conf.outputSize
  x.times do |xi|
    y.times do |yi|
      z.times do |zi|
        address = [xi,yi,zi]
        wave[address] = Wavelet.new(address,patterns)
      end
    end
  end

  wave
end

def printZ(conf,wave,z=0)
  # puts wave
  x,y,_ = conf.outputSize
  x.times do |xi|
    row = []
    y.times do |yi|
      address = [xi,yi,z]
      # puts "address: #{address.join(', ')}"
      wavelet = wave[address]
      if wavelet.resolved
        row.push(wavelet.resolved[0])
      else
        row.push("_")
      end
    end
    puts row.join(' ')
  end
end

class Wavelet
  PINNED="PINNED"
  UNDECIDED="UNDECIDED"
  DECIDED="DECIDED"
  def initialize(address,patterns)
    @address = address
    @state=UNDECIDED
    @patterns = patterns
    @pinned = pinned

    @weightRanges = []

    # generate hash map of {pattern => boolean} to store
    # whether or not each pattern is allowed at this
    # location
    @allowedPatterns = @patterns.keys

    @valid = false
    @resolved = nil
    self.clear
    self.recalculate    
  end
  def pin
    @pinned = true
    @state=PINNED
  end
  def pinned
    @state == PINNED
  end
  def address
    @address
  end
  def allows(pattern)
    not @allowedPatterns.index(pattern).nil?
  end
  def allowed
    @allowedPatterns.clone
  end
  def patterns
    @patterns.keys.clone
  end
  def clear
    @weightLogWeights = {}
    @sumOfWeights = 0.0
    @sumOfWeightLogWeights = 0.0
  end
  def recalculate
    # puts "recalculating..."
    self.clear

    self.allowed.each do |pat|
      weight  = @patterns[pat]
      @sumOfWeights += weight.to_f

      # for use in weighted random selection
      @weightRanges.push([@sumOfWeights, pat])

      # calculate the Shannon Entropy
      @weightLogWeights[pat] = weight * Math.log(weight)
      
      @sumOfWeightLogWeights += @weightLogWeights[pat]
    end

    if @sumOfWeights == 0 then
      @entropy = 0.0
      return
    end
    @entropy = Math.log(@sumOfWeights) - @sumOfWeightLogWeights / @sumOfWeights

    @valid = true
    nil
  end
  def ban(pattern)
    if @allowedPatterns.index(pattern).nil? then
      # puts "could not find #{pattern} in allowed patterns"
      return
    end
    # puts "banning #{pattern}"
    deleted = @allowedPatterns.delete(pattern)
    # puts "deleted: #{deleted} left: #{@allowedPatterns.size}"
    if @allowedPatterns.size == 0 then
      puts "exception banning pattern:"
      printPattern(pattern)
      raise "zero patterns allowed in #{self}"
    end
    # invalidate entropy calculation
    @valid = false
    nil
  end
  def entropy
    return 0.0 if @state == DECIDED
    self.recalculate if not @valid
    @entropy
  end
  def select
    self.recalculate if not @valid
    u = rand
    @weightRanges.find{|prob,pattern| @allowedPatterns.index(pattern) and (prob / @sumOfWeights) > u}.last
  end
  def collapse
    # puts "collapsing #{self}"
    if self.allowed.size == 1 then
      @resolved = @allowedPatterns[0]
    else
      @resolved = self.select 
      @allowedPatterns = [@resolved]
    end

    @state = DECIDED
    @resolved
  end
  def state
    @state
  end
  def resolve(val)
    @state = DECIDED
    @resolved = val
  end
  def resolved
    @resolved
  end
  def to_s
    "<#{@address.join(',')}:#{@state}>"
  end
  def inspect
    "#{self.to_s}"
  end
end
