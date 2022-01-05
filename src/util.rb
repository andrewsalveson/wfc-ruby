require(File.expand_path('./constants.rb', File.dirname(__FILE__)))
require(File.expand_path('./types.rb', File.dirname(__FILE__)))
require(File.expand_path('./cell.rb', File.dirname(__FILE__)))
require(File.expand_path('./grid.rb', File.dirname(__FILE__)))
require(File.expand_path('./wave.rb', File.dirname(__FILE__)))
require(File.expand_path('./pattern.rb', File.dirname(__FILE__)))

# get all patterns from a given cell
def cellPatterns(conf,grid,cellCoords)
  x,y,z = cellCoords
  dims = gridDims(grid)
  px,py,pz = conf.patternSize

  # create blank pattern
  pattern = Array.new(px){Array.new(py){Array.new(pz)}}
  
  # populate pattern from grid
  px.times do |patx|
    py.times do |paty|
      pz.times do |patz|
        # calculate offset
        ox = x - patx
        oy = y - paty
        oz = z - patz
        # calculate final
        final = wrap(conf,dims,[ox,oy,oz])
        # puts "using #{dims} wrapped #{[ox,oy,oz]} to #{final}"
        # get grid value
        v = getValue(conf,grid,final)
        # puts "+ #{x},#{y},#{z} = #{ox},#{oy},#{oz} => #{final} (#{v})"
        pattern[patx][paty][patz] = v
      end
    end
  end
  patterns = [pattern]
  if conf.rotations then
    t = pattern
    3.times do |i|
      t = rotateXY(t)
      # puts "rotation #{i}: #{t}"
      patterns.push(t)
    end
  end
  if conf.reflections then
    reflected = []
    patterns.each do |p|
      reflected.push(reflectX(p))
      reflected.push(reflectY(p))
    end
    reflected.each{|pn| patterns.push(pn)}
  end
  patterns
end

def allPatterns(conf,grid)
  dims = gridDims(grid)
  gx,gy,gz = dims
  px,py,pz = conf.patternSize
  # map of pattern => count
  unique = {}
  gx.times do |x|
    gy.times do |y|
      gz.times do |z|
        cellPatterns(conf,grid,[x,y,z]).each do |pn|
          if unique[pn].nil? then
            unique[pn] = 1
          else
            unique[pn] += 1
          end
        end
      end
    end
  end
  unique
end

def normalizeWeights(patterns)
  normalized = {}
  count = patterns.size
  patterns.entries.each do |k,v|
    normalized[k] = v / count.to_f
  end
  normalized
end

def printEntropy(wave,level=0)
  sig = 1
  t = (10**sig).to_f
  out = []
  wave.values.each do |wavelet|
    x,y,z = wavelet.address
    next if z != level
    out[x] = [] if out[x].nil?
    # float.round(n) does not exist in Ruby 1.6
    case wavelet.state
    when Wavelet::UNDECIDED
      out[x][y] = (wavelet.entropy * t).round / t
    when Wavelet::DECIDED
      val = wavelet.resolved
      out[x][y] = (val.nil? ? "_" : "#{val[0]}").ljust(sig + 2,".")
    when Wavelet::CONTRADICTION
      out[x][y] = "!" * (sig + 2)
    end
  end
  puts ""
  out.reverse.each do |row|
    puts "      " + row.join(' ')
    puts ""
  end
end

# input is an 3-dimensional array of cells
def wfc(conf,wave)
  return wave unless conf.solve

  currentLoop = 0

  undecided = wave.entries
  while undecided.size > 0 do
    if currentLoop > conf.stopAfter then
      puts "hit conf.stopAfter limit"
      break
    end

    printEntropy(wave) if conf.debug

    # get the wavelet with the lowest entropy
    address,wavelet = undecided.sort_by{|k,w| w.entropy }.shift

    # puts "triggering new collapse"
    wavelet.collapse
    toPropagate = propagate(conf,wave,wavelet)

    puts "starting propagation loop with #{toPropagate.size} wavelets" if conf.debug
    # the propagation loop is where the majority of pattern
    # resolution and wavelet collapse happens
    propagationLoopLimit = conf.propagationLimit
    currentPropagationLoop = 0
    numToPropagate = toPropagate.size
    while numToPropagate > 0 do
      if currentPropagationLoop > propagationLoopLimit then
        puts "ran over propagation limit (#{propagationLoopLimit})"
        break
      end
      currentWavelet = toPropagate.shift
      numToPropagate = toPropagate.size

      next if currentWavelet.nil?

      if currentWavelet.state == Wavelet::DECIDED then
        puts "wavelet decided, skipping" if conf.debug
        next
      end

      toPropagate += propagate(conf,wave,currentWavelet)
      numToPropagate = toPropagate.size

      currentPropagationLoop += 1
    end

    # prepare for next loop
    undecided = wave.entries.select{ |k,w| w.state == Wavelet::UNDECIDED }
    currentLoop += 1
  end
  
  wave
end

def patternsMustMatch(wavelet,whitelist,atOffset)
  # puts "---> #{self} propagating #{values.size} matches @ #{atOffset}"
  # keep track of whether or not this wavelet has been
  # changed by this pattern match requirement
  changed = false
  return changed if wavelet.state != Wavelet::UNDECIDED

  ox,oy,oz = atOffset
  wavelet.allowed.each do |pattern|
    value = pattern[ox][oy][oz]
    next if not whitelist.index(value).nil? # not nil, so the value was found
    
    # we couldn't find the required value in our whitelist
    wavelet.ban(pattern)
    changed = true
  end

  # if wavelet.allowed.size == 1 then
  #   # puts "===> matching values resulted in 1 possible value"
  #   wavelet.collapse
  #   changed = true
  # end

  changed
end

def propagate(conf,wave,wavelet)
  # keep track of which neighbors were
  # changed by the propagation of this 
  # pattern so that they can further 
  # propagate changes
  changed = []

  # iterate over the neighborhood surrounding
  # this address
  cx,cy,cz = wavelet.address
  
  puts "propagating #{wavelet.allowed.size} allowed patterns from #{wavelet.address}" if conf.debug

  # this is really a convolution map
  # NEIGHBORHOOD.map do |ndiff|
  NEIGHBORHOOD_DIAG.each_with_index do |ndiff,i|
    dx,dy,dz = ndiff

    ncoords = [cx+dx, cy+dy, cz+dz]
    neighbor = wave[ncoords]
    next if neighbor.nil?

    before = neighbor.allowed.size

    # # if this neighbor is already at 1 pattern all we can do
    # # is break it
    # next if before == 1

    # puts "--- propagating #{wavelet.allowed.size} to neighbor #{i}: #{neighbor}"

    # patternSelect is the offset of the current pattern that
    # the given neighbor is going to need to match
    # for example, if the current pattern is:
    #
    #             a  b 
    #            [c] d    (where [] indicates the current tile)
    #
    # ... then a Y+1 pattern will need to match "a",
    #          a Y-1 pattern will need to match "c",
    #          a X+1 pattern will need to match "d" and so on
    #
    patternSelect,nb = NEIGHBOR_MATCH[ndiff]
    px,py,pz = patternSelect

    # build a whitelist of values from
    # the wavelet
    whitelist = wavelet.allowed.map{|pat| pat[px][py][pz]}.uniq

    
    begin
      patternsMustMatch(neighbor,whitelist,nb)
    rescue RuntimeError => e
      puts "failure matching neighbor at #{ncoords} from #{wavelet}: #{e.message}"
      puts "fatal whitelist:"
      whitelist.each do |v|
        puts "#{v}"
      end
      raise "failure propagating to neighbor"
    end

    # if neighbor.allowed.size == 1 and neighbor.state == Wavelet::UNDECIDED then
    #   neighbor.collapse
    # end

    after = neighbor.allowed.size

    changed.push(neighbor) if before != after
  end

  puts "---> #{changed.size} neighbors were changed by propagation" if conf.debug

  changed
end
