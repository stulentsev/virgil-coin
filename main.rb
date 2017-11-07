require 'awesome_print'
require 'json'
require 'ostruct'
require 'ruby-progressbar'

require_relative 'api_wrapper'

@wrapper = ApiWrapper.new

def calc_time_to_ps(data, delta = 0)
  ps_cost    = 100_000_000_000
  rate = data.pointsPerSecond + delta
  ((ps_cost - data.points) / rate).round
end

def print_ps_banner(data)
  time_to_ps = calc_time_to_ps(data)

  from_now   = secs_to_moment(time_to_ps)
  puts ('-' * 80).yellowish
  puts '|'.yellowish +
         "Time until can buy PS: #{time_to_ps.round} secs (or #{secs_to_time(time_to_ps)} (tomorrow at #{from_now}))".center(78) +
         '|'.yellowish
  puts ('-' * 80).yellowish
end

def pretty_sleep(secs)
  progress = ProgressBar.create(total: secs, title: "Sleeping")
  secs.to_i.times do
    sleep(1)
    progress.increment
  end
rescue
  # do nothing
end

def eta(unit, data)
  cost         = unit.cost.send('1')
  have_already = data.points
  need_to_have = cost - have_already
  need_to_have / data.pointsPerSecond
end

def should_buy_unit?(unit, data)
  eta(unit, data) < calc_time_to_ps(data)
end

def can_buy_unit?(unit, data)
  eta(unit, data) < 0
end

def secs_to_time(secs)
  hours, secs = secs.divmod(3600)
  mins, secs  = secs.divmod(60)
  "%02d:%02d:%02d" % [hours, mins, secs]
end

def secs_to_moment(secs)
  (Time.now + secs).strftime('%H:%M:%S')
end

def maybe_buy_unit(best_unit, data)
  unless should_buy_unit?(best_unit, data)
    `say Buy play station now!`
    return
  end

  if can_buy_unit?(best_unit, data)
    @wrapper.build(best_unit.type)
    msg = "Bought #{best_unit.type}!"
    puts msg.redish
    `say #{msg}`
  end
end

loop do
  begin
    data = @wrapper.init.data

    print_ps_banner(data)

    units_by_profit = data.units.sort_by do |unit|
      unit.costPerCoin = unit.cost.send('1').fdiv(unit.itemProduction).round
    end

    units_by_profit.each_with_index do |unit, idx|
      time = eta(unit, data)
      new_time_to_ps = calc_time_to_ps(data, unit.itemProduction)

      msg = if time < 0
        "#{unit.type}: cost per coin (#{unit.costPerCoin}), can buy NOW, changes time to PS to #{secs_to_moment(new_time_to_ps)}"
      else
        "#{unit.type}: cost per coin (#{unit.costPerCoin}), can buy in #{time.round} seconds, changes time to PS to #{secs_to_moment(new_time_to_ps + time)}"
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

    maybe_buy_unit(best_unit, data)
    pretty_sleep(eta(best_unit, data))
  rescue => ex
    puts ex.message
    puts ex.backtrace
    sleep(2)
    retry
  end
end
