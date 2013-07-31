# -*- coding: Windows-31j -*-

require 'rubygems'
require 'fileutils'
require 'sqlite3'
require 'csv'

DB = "./dev.db"

class Attend
  attr_accessor :login_id, :user_no, :user_name, :lecture_class, :lecture_count, :attendance

  def initialize
    @attend
  end

  def export(cn)
    sql = <<-EOF
      insert into attends (login_id,  user_name, lecture_count, attendance)
                  values ( '#{login_id}', '#{user_name}','#{lecture_count}',1);
    EOF
    cn.execute(sql)
  end
end


def parse(cn)
  lines = []
  Dir.glob("./input/[0-9]*.csv") { |file|
    lec_cnt = File.basename(file, ".csv")
    delete_data(cn,lec_cnt)
    CSV.foreach(file) { |row|
      next if row[0] !~ /^[a-z]/
      row1 = row.push(lec_cnt)
      lines << row1.push(lec_cnt)
    }
  }

  #1行目はヘッダーのため削除
  lines.shift

  attends = []
  attend = nil
  lines.each do |line|
    u_id, u_name, comment, room, c_name, in_date, out_date, stay_time, start_date, end_date, lec_time, memo, lec_cnt = line
    attend = Attend.new
    attend.login_id = u_id
    attend.user_name = u_name
    attend.lecture_count = lec_cnt
    attends << attend
  end
  attends
end


def output(cn)
  cnt = nil
  sql = "select distinct(lecture_count) from attends"
  cnt = cn.execute(sql)
  cnt.each do |c|

    sql = <<-EOF
    select s.login_id, s.user_number, s.user_name, s.lecture_class, case when a.login_id is not null then 1 else  null end as attendance
      from students s left join (select * from attends where lecture_count = #{c[0]}) a
        on s.login_id = a.login_id order by s.lecture_class, s.user_number;
    EOF
    results = []
    cn.execute(sql){|row|
      results << row
    }

    FileUtils.mkdir_p("./output") unless FileTest.exist?("./output")
    CSV.open("./output/result_#{c[0]}.csv","wb:windows-31j"){|file|
      file << ['ログインID', 'ユーザーNo', '氏名', 'クラス', '出欠']
      results.each{|result|
        file << result
      }
    }
  end

  cn.close
end

def get_connection
  cn = SQLite3::Database.new(DB)
  cn
end

def delete_data(cn, lec_cnt)
  sql="delete from attends where lecture_count = #{lec_cnt};"
  cn.execute(sql)
end

def main
  p "開始"
  cn = get_connection
  attends = parse(cn)
  p "読込中..."
  attends.each do |attend|
    attend.export(cn)
  end
  p "出力中..."
  output(cn)
  p "完了"
end

main