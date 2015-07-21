require 'whois'
require 'ruby-progressbar'

def highlight(str)
  str
    .gsub(/([Rr]egistrar\.*:)/, '<strong>\1</strong>')
    .gsub(/([Dd]omain\s*[Nn]ame\.*:)/, '<strong>\1</strong>')
end

names = File.read('./names').split(/\s/).select {|s| s != '' }

#tld_list = %w(.com .net .eu .fr)
tld_list = Whois::Server.definitions.fetch(:tld).map(&:first)

whois = Whois::Client.new

doc = File.open("/tmp/all-tld-whois-#{Time.now.strftime("%F-%T")}.html", 'w')
doc.write('<html>')
doc.write(<<HEAD
<head>
  <style>
    strong { 
      color: red;
    }
  </style>
</head>
HEAD
)
doc.write('<body>')


names.each do |name|
  puts name
  progressbar = ProgressBar.create(total: tld_list.size)

  tld_list.each do |tld|
    domain = name + tld
    begin
      str = whois.lookup(domain)
    rescue
      str = "<b>ERROR</b>"
    end

    doc.write("<h1>#{domain}</h1>\n\n")
    doc.write("<code><pre>#{highlight(str.to_s)}</pre></code>\n")
    doc.write("<hr>")

    progressbar.increment
  end
end

doc.write('</body>')
doc.write('</html>')
doc.close
