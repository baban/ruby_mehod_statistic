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
    open("method_missings.txt","w") do |f|
      result = base_dirs.each do |dir|
        p dir;
        s = scans(dir)
        f<< s*"\n"
      end
    end
  end

  def self.parsable_gems
    base_dirs = Dir.glob("gems/*")
  end

  def self.rb_files(root_path)
    Dir.glob(File.join(root_path,"/lib/**/*.rb"))
  end

  def self.scans(dir)
    rb_files(dir).map{ |file| p file; s=squueze_method_missing(file); s }.flatten.compact
  end

  def self.squueze_method_missing(file)
    stream = File.open(file, "r", encoding: Encoding::UTF_8).read
    stream.scan(/(((^)[ \t]*?)def (method_missing|respond_to_missing)(.+?\n){1,40})/m) do |m|
      #return [file, m[0].gsub(m[1],m[2])]
      return [file, m[0]]
    end
    nil
  end
end

#open("method_missings.txt","w") { |f| f<< RubyStatics.squueze_method_missing("./gems/stripe-2.9.0/lib/stripe/stripe_object.rb")[1] }

pp RubyStatics.exec
