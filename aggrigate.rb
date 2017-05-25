require 'parser/current'
require "pry"
require 'faraday'
require 'nokogiri'
class RubyStatics
  module HashExtend
    refine Hash do
      def sum_merge(hash)
        hash.reduce(self){ |h,(k,v)| h[k] ||= 0; h[k] += v; h }
      end
    end
  end
  using HashExtend

  def self.exec(root_path="gems/")
    # top500のgemの名前を取得する
    ranking = generate_gem_ranking((500/20).to_i)
    # top500のgemを指定のディレクトリにダウンロードして展開する
    ranking.each { |name| deploy_gem(name) }
    base_dirs = parsable_gems
    open("parsable_gems.rb", "w"){|f| f<< base_dirs.inspect }
    # 順番にファイルをパースしてメソッド名とその使用回数を抜き取っていく
    aggrigate_result = nil
    aggrigate_result = base_dirs.reduce({}){ |total, dir| p dir; h = parse_project(dir); total.sum_merge(h) }
    open("aggrigate_result.rb","w"){|f| f<< aggrigate_result.inspect }
    # ruby標準のライブラリにあるメソッド名だけに絞り込む
    dic = method_name_dictionary
    default_method_aggrigate_result = dic.reduce({}){ |h,(k,v)| h[k] = aggrigate_result[k] || 0; h }
    # 結果を使用回数でソートする
    sort_result = default_method_aggrigate_result.sort{ |a,b| b[1]<=>a[1] }
    open("result.txt"){|f| f<< sort_result.inspect }
    sort_result
  end

  def self.generate_gem_ranking(max_page=5)
    ranking = (1..max_page).map do |page|
      response = Faraday.get("http://bestgems.org/total?page=#{page}")
      body = response.body
      doc = Nokogiri::HTML.parse(body, nil, "UTF-8")
      names = doc.xpath('//div[@class="row-fluid marketing"]//table//tr')[1..-1].map do |tr|
        tr.xpath('td[3]/a/text()').to_s
      end
      names
    end.flatten
    ranking
  end

  def self.deploy_gem(name, version)
    `cd gems; gem fetch #{name} -v #{version}`
    `cd gems; gem unpack #{name}`
    `cd gems; mv *.gem ../cache`
  end

  def self.parsable_gems
    base_dirs = Dir.glob("gems/*")
  end

  def self.parse_project(root_dir)
    files = rb_files(root_dir)
    files.reduce({}) do |result,f|
      begin
        parse(f, result)
      rescue Parser::SyntaxError => e
        next result
      rescue => e
        next result
      end
      result
    end
  end

  def self.rb_files(root_path)
    Dir.glob(File.join(root_path,"/lib/**/*.rb"))
  end

  def self.parse(file, hash)
    #p file
    stream = File.open(file, "r", encoding: Encoding::UTF_8).read
    ast = Parser::CurrentRuby.parse(stream)
    #p ast
    # 空のファイルはパース結果がnilになる
    return hash unless ast

    method_names = squeeze_method_names(ast, [])
    method_names.each { |name| hash[name] ||= 0; hash[name] += 1 }
    hash
  end

  def self.squeeze_method_names(ast, result)
    ast.children.map do |child_node|
      if !child_node.is_a? Parser::AST::Node
        # nilを無視するs
      elsif child_node.type==:send
        method_name = child_node.to_a[1]
        result<< method_name
        squeeze_method_names(child_node, result)
      else
        squeeze_method_names(child_node, result)
      end
    end
    return result
  end

  def self.method_name_dictionary
    ObjectSpace.each_object(Class).inject({}) do |h,klass|
      klass.instance_methods.each{ |k| h[k]||=[]; h[k]<< klass }
      klass.methods.each { |k| h[k]||=[]; h[k]<< klass }
      h
    end
  end
end

hash = RubyStatics.exec()
#p hash.to_a.sort{ |a,b| b[1]<=>a[1] }.reduce({}){ |h,(k,v)| h[k]=v; h }
