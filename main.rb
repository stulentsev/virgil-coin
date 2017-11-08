require 'bundler'
Bundler.require

require_relative 'api_wrapper'

@wrapper = ApiWrapper.new

def calc_time_to_ps(data, rate_delta: 0, points_delta: 0)
  ps_cost        = 100_000_000_000
  remaining_cost = ps_cost - data.points + points_delta
  rate           = data.pointsPerSecond + rate_delta

  (remaining_cost / rate).round
end

def print_ps_banner(data)
  time_to_ps = calc_time_to_ps(data)

  from_now = secs_to_moment(time_to_ps)
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
ensure
  sleep(1) # just in case
end

def eta(unit, data)
  cost         = unit.cost.send('1')
  have_already = data.points
  need_to_have = cost - have_already
  need_to_have / data.pointsPerSecond
end

def should_buy_unit?(unit, data)
  base_ps_eta          = calc_time_to_ps(data)
  is_cheaper_than_ps = eta(unit, data) < base_ps_eta

  ps_eta_with_new_unit = calc_time_to_ps(
    data,
    rate_delta:   unit.itemProduction,
    points_delta: -unit.cost.send('1')
  )
  will_shorten_time    = base_ps_eta > ps_eta_with_new_unit

  is_cheaper_than_ps && will_shorten_time
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
  if can_buy_unit?(best_unit, data)
    return unless should_buy_unit?(best_unit, data)
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

    rows = units_by_profit.map do |unit|
      time = eta(unit, data)

      [
        unit.type,
        unit.costPerCoin,
        unit.itemProduction,
        time < 0 ? 'NOW' : "in #{time.round} seconds",
      ]
    end
    puts Terminal::Table.new(
      headings: [
                  'Unit Type',
                  'Cost Per Coin',
                  '+ rate',
                  'When can buy?',
                ],
      rows:     rows,
    )

    best_unit = units_by_profit.first

    maybe_buy_unit(best_unit, data)
    # sleep(3)
    pretty_sleep(eta(best_unit, data))
  rescue => ex
    puts ex.message
    puts ex.backtrace
    sleep(2)
    retry
  end
end
