require 'date'
require 'hashie'

class Hataraki
  SHIFT_PATTERN = Hashie::Mash.new({early: 0, late: 1, rest: 2})
  SHIFT_ROUTINE = [
      SHIFT_PATTERN.early, SHIFT_PATTERN.early, SHIFT_PATTERN.rest, SHIFT_PATTERN.rest,
      SHIFT_PATTERN.early, SHIFT_PATTERN.early, SHIFT_PATTERN.rest, SHIFT_PATTERN.rest,
      SHIFT_PATTERN.late, SHIFT_PATTERN.late, SHIFT_PATTERN.rest, SHIFT_PATTERN.rest,
      SHIFT_PATTERN.late, SHIFT_PATTERN.late, SHIFT_PATTERN.rest, SHIFT_PATTERN.rest,
  ]

  CRITERIA_DAYS = [
      Date.parse('2020-10-17'),
  ]

  def shift_of_day(target_date)
    period_start_day = CRITERIA_DAYS[search_period_index(target_date)]
    SHIFT_ROUTINE[(target_date - period_start_day).to_i % 16]
  end

  def get_shift_pattern(target_date)
    pattern = shift_of_day(Date.parse(target_date))
    case pattern
    when SHIFT_PATTERN.early
      "#{target_date} はアーリーだよ"
    when SHIFT_PATTERN.late
      "#{target_date} はレイトだよ"
    else
      "#{target_date} はお休みだよ"
    end
  end

  private

  def search_period_index(target_date)
    date_delta = CRITERIA_DAYS.map { |d| (d - target_date).to_i }.filter { |d| d <= 0 }
    date_delta.find_index(date_delta.max)
  end
end
