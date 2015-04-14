#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'
require 'watir-webdriver'
require 'headless'
require 'stringex'
#$VERBOSE = true
#
#
## ####################################################################
#**注意**  
# 更新于2015-04-15  
# 该脚本已经重写，做成了RubyGem。  
# 使用说明请参见如下链接：  
# https://github.com/yanyingwang/cnblog2jekyll  
## ####################################################################
#
#
#
#
# ####################################################################
#
#
# This script is used to export blog from cnblog(cnblog.com) to Jekyll.
#
# Find and view it at link here:
# https://github.com/wyying/ruby_scripts/blob/master/export_cnlog_to_jekyll.rb
#
# Download and update it at link here:
# https://raw.githubusercontent.com/wyying/ruby_scripts/master/export_cnlog_to_jekyll.rb
#
#
# ####################################################################
#
#
# The MIT License (MIT)
#
# Copyright (c) 2014 WangYanying
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#
# ####################################################################
#
#
#
#
# 说明部分 #
#
# 该脚本的作用:
#     1, 该脚本适用于想要把个人博客中cnblog迁移到jekyll的用户. 
#     2, 需要注意的是, cnblog网站的管理内容提供迁移博客的方法, 但是导出的文章内容是xml格式而且不带有文章分类标签. 
#     3, 该脚本可以抓取cnblog的博客文章然后转化成jekyll的post标准格式.
#     4, 该脚本的运行环境在下面"运行脚本的环境"里面有详细说明.
#     
#
#
#
# 注意:
#     1, 如果文章设置了访问密码, 导出时请暂时取消密码, 否则无法导入相关随笔.
#     2, 转换后的随笔分类名字统一为小写字母.
#     3, 如果分类名字为中文的, 请尽量在转换前将分类名字更换为英文, 并且等待10分钟左右等待页面生效.否则, 转换后的分类标签将额外附加提供一个"汉语拼音"的分类名字.
#     
#
#
#
#
#
# 使用方法:          
#     1, 运行脚本时跟上参数username, 如下:
#       ./export_cnlogs_to_jekyll.rb username
#     2, username应该是什么:
#       例如url是http://cnblogs.com/yywang, 则username就是yywang. 那么使用方法就是./export_cnblogs_to_jekyll.rb yywang
#
#
#
#
#
# 脚本运行环境:
#     1, 如果脚本的运行系统环境是Ubuntu系统, 安装依赖, 请执行如下命令:
#         aptitude install xvfb firefox
#     2, 对于ruby库环境, 安装依赖, 请执行如下命令:
#         gem install nokogiri watir-webdriver headless stringex
#
#
#
#
# 脚本处理过程解释:  
#     该脚本会打开http://cnblogs.com/username地址然后根据"随笔档案"获取相关用户的每篇文章地址, 然后获取文章内容部分和相关分类信息. 
#
#
#
# 输出结果解释:          
#     该脚本运行完毕之后, 会在运行目录下面生成"_posts/cnblogs"目录, 脚本抓取到的文章, 将以jekyll的post标准方式保存即: 文件名date-title.markdown, 内容为yaml格式.
#
#
# ####################################################################
#
#
#
#
#


def get_archive_links(username)
  headless = Headless.new
  headless.start

  browser = Watir::Browser.start 'cnblogs.com/' + username
  html = Nokogiri::HTML.parse(browser.html)
  links = []; html.css('div#blog-sidecolumn a').each do |e| 
    links << e['href'] if e['href'] =~ /archive/
  end

  browser.close
  headless.destroy

  links
end

def get_article_links(url)
  html = Nokogiri::HTML(open(url))
  links = []; html.css('div.post h5 a').each { |e| links << e['href'] }
  links
end

def get_article(url)
  headless = Headless.new
  headless.start

  browser = Watir::Browser.start url
  html = Nokogiri::HTML.parse(browser.html)
  title = html.css('a#cb_post_title_url').text.gsub("\"","")
  date = html.css('span#post-date').text
  content = html.css('div#cnblogs_post_body').to_s.each_line.to_a[1...-1].join("\n").gsub(/\r\n/, "\n")
  category = []; 
  html.css('div#BlogPostCategory a').each do |e| 
    category << e.text.downcase
    category << e.text.to_url if e.text =~ /\p{Han}+/
  end
  dirname = "_posts/cnblogs"
  filename = date.match(/....-..-../).to_s + "-" + title.scan(/[a-zA-Z0-9\p{Han}]+/).join("-") + ".markdown"
  content = <<-EOF.gsub(/^\s+/, "")
  ---
  layout: post
  title: "#{title}"
  date: "#{date} +0800"
  comments: true
  categories: [ #{category.join(", ")} ]
  ---
  #{content}
  EOF

  browser.close
  headless.destroy

  Dir.mkdir(dirname.split("/")[0]) unless Dir.exist?(dirname.split("/")[0])
  Dir.mkdir(dirname) unless Dir.exist?(dirname)
  if File.open(dirname + "/" + filename, 'w') { |f| f.write(content) }
    puts <<-EOF

    article links:    #{url}
    generate file:    #{dirname}/#{filename}
    EOF
  end
end


if ARGV.empty?
  puts <<-EOF
  
  Usage :      #{$0} cnblog_username
  Example :    #{$0} yywang

  EOF
  exit
end

articles_links = []
archives_links = get_archive_links(ARGV[0])
archives_links.each { |e| articles_links.concat(get_article_links(e)) }
articles_links.each { |e| get_article(e) }


