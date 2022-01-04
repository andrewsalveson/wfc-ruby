# error types
class AssertionError < RuntimeError
end

class EqualityError < AssertionError
end

# globals
$TEST_SUITES = []
$TEST_OUTPUT = {}
$TEST_ERRORS = {}
$TEST_LEVEL = 0
INDENT = '   '

# assertions
def assert(&block)
  raise AssertionError unless yield
end

def assertThrows(&block)
  threw = false
  begin
    yield
  rescue
    threw = true
  end
  assert{threw == true}
end

def assertEquals(a,b)
  return if a == b
  puts " wanted #{b}"
  puts "but got #{a}"
  # puts "expected #{a} to equal #{b}"
  raise EqualityError
end

# block and test executors
def runBlock(&block)
  raise RuntimeError unless yield
end

def describe(descname,block)
  puts INDENT * $TEST_LEVEL + descname
  errs = []
  $TEST_SUITES.push(descname)
  $TEST_OUTPUT[descname] = []
  $TEST_ERRORS[descname] = []
  $TEST_LEVEL += 1

  # execute suite
  block.call
  
  $TEST_LEVEL -= 1
  errors = $TEST_ERRORS[$TEST_SUITES.last]
  output = $TEST_OUTPUT[$TEST_SUITES.last]
  if not errors.size == 0 then
    output.each{|n| puts " " + INDENT * $TEST_LEVEL + n}
    errors.each{|e| raise e}
  elsif output.size != 0 then
    puts INDENT * $TEST_LEVEL + "✅ #{output.size}"
  end
  $TEST_SUITES.pop
end

def it (itname, block)
  begin
    # execute test
    block.call
  rescue RuntimeError => e
    $TEST_OUTPUT[$TEST_SUITES.last].push("❌ #{$TEST_SUITES.join(' > ')} > #{itname}")
    $TEST_ERRORS[$TEST_SUITES.last].push(e)
  else
    $TEST_OUTPUT[$TEST_SUITES.last].push("✅ #{itname}")
  end
end
