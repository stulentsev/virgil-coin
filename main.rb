require 'awesome_print'
require 'json'
require 'ostruct'
require 'ruby-progressbar'

require_relative 'api_wrapper'

wrapper = ApiWrapper.new

def pretty_sleep(secs)
  progress = ProgressBar.create(total: secs, title: "Sleeping")
  secs.to_i.times do
    sleep(1)
    progress.increment
  end
end

def eta(unit, data)
  cost = unit.cost.send('1')
  have_already = data.points
  need_to_have = cost - have_already
  need_to_have / data.pointsPerSecond
end

def can_buy_unit?(unit, data)
  eta(unit, data) < 0
end

loop do
  data = wrapper.init.data
  # ap data.points
  # ap data.pointsPerSecond
  units_by_profit = data.units.sort_by do |unit|
    unit.costPerCoin = unit.cost.send('1').fdiv(unit.itemProduction).round
  end

  units_by_profit.each_with_index do |unit, idx|
    time = eta(unit, data)

    msg = if time < 0
      "#{unit.type}: cost per coin (#{unit.costPerCoin}), can buy NOW"
    else
      "#{unit.type}: cost per coin (#{unit.costPerCoin}), can buy in #{time.round} seconds"
    end

    msg = case idx
    when 0
      msg.greenish
    when 1, 2
      msg.yellowish
    else
      msg
    end
    puts msg
  end

  best_unit = units_by_profit.first
  if can_buy_unit?(best_unit, data)
    wrapper.build(best_unit.type)
    puts "Bought #{best_unit.type}!".yellowish
  end

  pretty_sleep(eta(best_unit, data))
end
