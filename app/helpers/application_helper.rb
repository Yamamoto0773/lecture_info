module ApplicationHelper
  # 時刻から何時限目かを求める
  def to_ordinal_range(time_range)
    beg_ordinal = 0, end_ordinal = 0

    Settings.lecture.time_table.each_with_index { |time, i|
      if time[:from] == time_range.begin.strftime('%H:%M:%S')
        beg_ordinal = i+1
      end
      if time[:to] == time_range.end.strftime('%H:%M:%S')
        end_ordinal = i+1
      end
    }

    beg_ordinal..end_ordinal
  end

  # 時刻から何コマ目か求める
  def to_cell_range(time_range)
    range = to_ordinal_range(time_range)
    beg_cell = (range.begin + 1) / 2
    end_cell = (range.end + 1) / 2

    beg_cell..end_cell
  end

  def date_format(time_range)
    cell = to_cell_range(time_range)
    
    str = ""
    str << I18n.l(time_range.begin.to_date, format: :date)
    str << ' '
    str << "#{cell.begin}"
    str << "〜#{cell.end}" if cell.begin != cell.end
    str << 'コマ目'
  end
end
