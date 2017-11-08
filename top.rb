require 'awesome_print'
require 'json'
require 'ostruct'
require 'ruby-progressbar'
require 'terminal-table'

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
SLEEP_PERIOD = 120

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
      'time to ps',
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
          secs_to_moment(time_to_ps(user)),
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
          secs_to_moment(time_to_ps(user)),
        ]
      end
    end.sort_by(&:last).tap do |aary|
      aary[0][-1] = aary[0][-1].to_s.greenish if aary[0][1] == 'ME!'
      aary[1][-1] = aary[1][-1].to_s.yellowish if aary[1][1] == 'ME!'
      aary[2][-1] = aary[2][-1].to_s.yellowish if aary[2][1] == 'ME!'
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
