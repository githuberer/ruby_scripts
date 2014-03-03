#!/usr/bin/env ruby
require 'mysql2'
# crontab: 00:10 (every day)
# 20 0 * * *  scriptpath


$client = Mysql2::Client.new(
  :as => :array,
  :host => '10.0.0.250',
  :username => 'mysql',
  :password => '123456',
  :database => 'test'
)

$table_names = [ "test1", "test2", "test3" ]
$date = Time.now.strftime('%Y%m')


def rearrenge_table(table_name, num)   # num: how many days
  ### get ids from table_name
  ids = []
  $client.query("
                SELECT id FROM #{table_name}
                WHERE createDate < curdate()-interval #{num} day
                ").each { |e| ids << e }
    ids.flatten!

    puts <<-header
    ==============================
    #{Time.now}
    ==============================
    id:            #{ids.inspect}
    table_name:    #{table_name}
    records size:  #{ids.size}
    header

  until ids.empty?
    ids_new = ids.shift(1000).join(", ")

    ### insert records to table_name_date
    puts "insert =================="
    table_name_date = table_name + "_" + $date
    $client.query(" CREATE TABLE IF NOT EXISTS #{table_name_date} LIKE #{table_name} ")
    $client.query("
                  INSERT INTO #{table_name_date}
                  SELECT * FROM #{table_name}
                  WHERE id IN ( #{ids_new} )
                  ")

    ### delete records from table_name
    puts "delete =================="
    $client.query("
                DELETE FROM #{table_name}
                WHERE id IN( #{ids_new} )
                  ")
  end
end


$table_names.each { |e| rearrenge_table(e, '30') }



