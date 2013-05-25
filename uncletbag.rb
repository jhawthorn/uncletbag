require 'srt'

Line = Struct.new(:startidx, :endidx, :line)
Result = Struct.new(:file, :text, :start_time, :end_time) do
  def to_s
    %{#{file} #{start_time} - #{end_time}\n#{text.join("\n")}\n}
  end
end

class Episode
  def initialize filename
    @filename = filename
    @fulltext = ""
    @lines = []
    file = SRT::File.parse(File.new(filename, "r:iso-8859-1"))
    file.lines.each do |line|
      text = line.text.join(" ")
      text.downcase!
      text.gsub!(/<\/?i>/,'')
      text.gsub!(/[^a-z]/,'')

      startidx = @fulltext.size
      @fulltext << text
      endidx = @fulltext.size

      @lines << Line.new(startidx, endidx, line)
    end
  end
  def search query
    pos = 0
    results = []
    while pos = @fulltext.index(query, pos)
      startidx = pos
      endidx = pos + query.length
      matching = @lines.select{|l| l.endidx > startidx && l.startidx < endidx }
      matching_lines =  matching.map(&:line)
      results << Result.new(@filename, matching_lines.map(&:text).flatten, matching_lines.map(&:start_time).min, matching_lines.map(&:end_time).max)
      pos = matching.map(&:endidx).max
    end
    results
  end
end


eps = Dir['subs/*.srt'].map do |filename|
  Episode.new(filename)
end

query = ARGV.join
query = query.downcase.gsub(/[^a-z]/,'')

results = eps.map do |ep|
  ep.search(query)
end.flatten

puts results.join("\n\n")

