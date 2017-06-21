require 'parser/current'
require "pry"
require 'faraday'
require 'nokogiri'
require 'yaml'

class RubyStatics
  def self.exec(root_path="gems/")
    # method_missingの利用箇所を正規表現で抜き取る

    base_dirs = parsable_gems
    # 順番にファイルをパースしてメソッド名とその使用回数を抜き取っていく
    result = base_dirs.reduce({}){ |total, dir| p dir; scans(dir) }
    # 抜き取った結果をテキストファイル状に出力する
    open("method_missings.txt","w") { |f| f<< result*"¥n" }

    result
  end

  def self.parsable_gems
    base_dirs = Dir.glob("gems/*")
  end

  def self.rb_files(root_path)
    Dir.glob(File.join(root_path,"/lib/**/*.rb"))
  end

  def self.scans(dir)
    rb_files(dir).map{ |file| squueze_method_missing(file, hash) }.flatten.compact
  end

  def self.squueze_method_missing(file, hash)
    p file
    #stream = File.open(file, "r", encoding: Encoding::UTF_8).read
    #stream.scan(/def method_missing.+$(.*$)[1-20]/)
  end
end

pp RubyStatics.exec
