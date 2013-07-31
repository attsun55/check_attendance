# -*- coding: Windows-31j -*-

require 'rubygems'
require 'sqlite3'
require 'csv'

# > ruby -Ks register.rb
# �ǂݍ���CSV�t�@�C���́A�w�Дԍ�,���O�C��ID,����,�N���X

DB = "./dev.db"

class Student
  attr_accessor :login_id, :user_number, :user_name, :lecture_class

  def export(cn)
    sql = <<-EOF
    insert into students (user_number, login_id, user_name, lecture_class)
                values ( '#{user_number}', '#{login_id}', '#{user_name}','#{lecture_class}');
    EOF
    cn.execute(sql)
  end
end

def parse
  file_name = get_file()
  lines = []
  CSV.foreach("./#{file_name}", encoding:'windows-31j' ) { |row|
    lines << row.push()
  }

  # �w�b�_�[�������O����
  lines.shift

  students = []
  student = nil
  lines.each do |line|
    user_number, login_id, user_name, lecture_class = line
    student = Student.new
    student.user_number = user_number
    student.login_id = login_id
    student.user_name = user_name
    student.lecture_class = lecture_class
    students << student
  end
  students
end

def get_connection
  cn = SQLite3::Database.new(DB)
  cn
end

def get_file
  input_file = nil
  File.open('./students_list.txt') do |file|
    input_file = file.read.chomp
  end
  input_file
end

def delete_data(cn)
  sql="delete from students"
  cn.execute(sql)
end

def main
  p "�J�n"
  cn = get_connection
  delete_data(cn)
  students = parse
  p "�Ǎ���..."
  students.each do |student|
    student.export(cn)
  end
  p "����"
end

main
