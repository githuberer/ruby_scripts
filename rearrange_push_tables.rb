#!/usr/bin/env ruby
require 'mysql2'
# crontab: 00:10 (every day)
# 20 0 * * *  scriptpath
#
# This script is used for split table for database monthly.
# Run this script every day in crontab.
#
# Example explaination:
# Records weekago from table: <requestlog> (requestlog from array $table_names_rearr_weekago) in database: <test> will be moved to table: <requestlog_201402>(201402 from string $date) daily.
#
# Modify variable as you need.
# $table_names_rearr_weekago: table name here will only exist records created last week.
# $table_names_rearr_monthago: table name here will only exist records created last month.


$client = Mysql2::Client.new(
  :as => :array,
  :host => '10.0.0.250',
  :username => 'mysql',
  :password => '123456',
  :database => 'test'
)

$table_names_rearr_weekago = %w{ requestlog }
$table_names_rearr_monthago = %w{ integrate linklog }
$date = Time.now.strftime('%Y%m')



def rearrenge_table(table_name, unit)   # unit: day, week, month
  ### get ids from table_name
  ids = []
  $client.query("
                SELECT id FROM #{table_name}
                WHERE createDate < curdate()-interval 1 #{unit}
                ").each { |e| ids << e }
  ids.flatten!

  puts table_name + "================="
  puts ids.inspect

  unless ids.empty?
    ### insert records to table_name_date
    table_name_date = table_name + "_" + $date
    $client.query(" CREATE TABLE IF NOT EXISTS #{table_name_date} LIKE #{table_name} ")
    $client.query("
                  INSERT INTO #{table_name_date}
                  SELECT * FROM #{table_name}
                  WHERE id IN ( #{ids.join(', ')} ) 
                  ")

    ### delete records from table_name
    $client.query("
                DELETE FROM #{table_name}
                WHERE id IN ( #{ids.join(', ')} )
                  ")

  end

=begin
=end
end


$table_names_rearr_monthago.each { |e| rearrenge_table(e, 'month') }
$table_names_rearr_weekago.each { |e| rearrenge_table(e, 'week') }



