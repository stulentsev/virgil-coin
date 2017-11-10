require 'bundler'
Bundler.require

require_relative 'api_wrapper'

@wrapper = ApiWrapper.new

def human_distance(delta)
  cutoffs = {
    1_000_000_000 => 'billion',
    1_000_000     => 'million',
    1_000         => 'thousands'
  }

  div, word = cutoffs.detect { |c, _w| c < delta.abs }

  if div
    [delta.fdiv(div).round(1), word].join(' ')
  else
    delta
  end
end

def secs_to_moment(secs)
  (Time.now + secs).strftime('%H:%M:%S')
end

def time_to_ps(user)
  cost           = 100_000_000_000
  remaining_cost = cost - user.currentWealth
  remaining_cost / user.production
end

my_id        = '4928530031813'
SLEEP_PERIOD = 30

last_top = []

loop do
  begin
    users = @wrapper.top.records

    headers = [
      'place',
      'user id',
      'wealth',
      'distance',
      'distance change/sec',
    ]

    me   = users.detect { |u| u.ticketNumber == my_id }
    rows = users.map.with_index do |user, idx|
      last_user = last_top.detect { |u| u.ticketNumber == user.ticketNumber }
      last_me   = last_top.detect { |u| u.ticketNumber == my_id }

      if user == me
        [
          idx + 1,
          'ME!',
          user.totalWealth.to_i,
          '-',
          '-',
        ]

      else
        distance      = (user.totalWealth - me.totalWealth).round
        last_distance = (last_user&.totalWealth.to_i - last_me&.totalWealth.to_i).round
        [
          idx + 1,
          user.ticketNumber,
          user.totalWealth.to_i,
          human_distance(distance),
          human_distance((distance - last_distance) / SLEEP_PERIOD),
        ]
      end
    end

    puts Terminal::Table.new(
      headings: headers,
      rows:     rows,
    )
    sleep(SLEEP_PERIOD)
  ensure
    last_top = users
  end
end
