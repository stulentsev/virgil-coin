require 'bundler'
Bundler.require

class Unit < OpenStruct
  def cost_per_coin
    cost.fdiv(production).floor
  end

  def inspect
    "#{name}: cost: #{cost}, cost per coin: #{cost_per_coin}, count: #{count}"
  end

end

def can_buy_ps?
  @wealth >= @ps_price
end

def secs_to_time(secs)
  hours, secs = secs.divmod(3600)
  mins, secs  = secs.divmod(60)
  "%02d:%02d:%02d" % [hours, mins, secs]
end

def find_best_unit
  @units.sort_by do |u|
    [
      u.cost_per_coin,
      u.cost, # cheaper first, if cost-per-coin equal
    ]
  end.first
end

def buy_unit(unit)
  @wealth     -= unit.cost
  @production += unit.production

  unit.count += 1
  unit.cost  *= 1.15
end

def should_buy?(unit)
  eta_without_unit = (@ps_price - @wealth) / @production
  eta_with_unit = (@ps_price - @wealth + unit.cost) / (@production + unit.production)

  # sleep(0.05)
  eta_with_unit < eta_without_unit
end

def wait(wait_time)
  puts "waiting #{wait_time} secs, wealth #{@wealth}, production: #{@production}"
  @current_time += wait_time
  @wealth       += wait_time * @production
end

def unit_by_name(name)
  @units.detect { |u| u.name == name }
end

@ps_price = 100_000_000_000_000.0
# @ps_price = 100_000_000_000_000_000_000_000.0

@units = [
  { name: 'Manual', cost: 16, production: 0.125, count: 0 },
  { name: 'Intel', cost: 128, production: 1, count: 0 },
  { name: 'Radeon', cost: 1024, production: 8, count: 0 },
  { name: 'Geforce', cost: 8192, production: 64, count: 0 },
  { name: 'Asic', cost: 131072, production: 256, count: 0 },
  { name: 'Farm', cost: 1048576, production: 2048, count: 0 },
  { name: 'Factory', cost: 16777216, production: 8192, count: 0 },
  { name: 'DataCenter', cost: 268435456, production: 65536, count: 0 },
  { name: 'Cloud', cost: 4294967296, production: 262144, count: 0 },
  { name: 'QuantumComputer', cost: 137438953472, production: 4193304, count: 0 },
].map { |h| Unit.new(h) }

@current_time = 0
@production   = 0

@wealth = 16 + 128 # initial clicking
buy_unit(unit_by_name('Manual'))
buy_unit(unit_by_name('Intel'))

# hand off to the bot
iteration = 0

loop do
  unit      = find_best_unit
  wait_time = (unit.cost - @wealth).fdiv(@production)
  puts "#{iteration}: best unit: #{unit.name} at #{unit.cost} (cost-per-coin #{unit.cost_per_coin})"

  if should_buy?(unit)
    wait(wait_time.ceil)
    buy_unit(unit)
  else
    sleep(0.5)
    puts "shouldn't buy #{unit.inspect}"
    wait_for_ps = (@ps_price - @wealth) / @production
    wait(wait_for_ps)
    break
  end

  break if can_buy_ps?
  iteration += 1
end

puts "wealth: #{@wealth}, production: #{@production}"
puts "Time elapsed: #{secs_to_time(@current_time)} (#{@current_time} secs)"
ap @units
