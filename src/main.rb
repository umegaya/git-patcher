require 'socket'
require 'json'
require File.expand_path("git", File.dirname(__FILE__))


class Patcher
	def initialize(host, port, repo, email)
		@host = host
		@port = port
		@git = Git.new(repo, email)
		#self.parse nil, true
	end
	def run 
		begin
			@s = Socket.tcp(@host, @port)
			while l = @s.gets
				r = self.parse l
			end
		rescue Exception => e
			puts "Patcher.run error:" + e.to_s + " @ " + e.backtrace.join("\n")
			@s.close if @s
			sleep 1
			retry
		ensure 
			@s.close if @s
		end
	end
	def parse(line, debug = false)
		if debug then
			line = <<JSON
{"Type":"message","Data":{"type":"message","channel":"C02BCC0AV","ts":"1443679573.000019","pinned_to":null,"attachments":[{"fallback":"\u003chttp://ift.tt/1LRtvNM\u003e","title":"[PATCH] test commit","text":"\u003chttp://ift.tt/1LRtvNM\u003e","mrkdwn_in":["text","pretext"]}],"subtype":"bot_message","username":"IFTTT","icons":{}}}
JSON
		end
		puts line
		o = JSON.parse line.chop
		self.process o
	end
	def process(obj)
		if obj["Type"] == "message" then
			msg = @git.process(obj["Data"])
			if msg then
				@s.puts(JSON.generate(msg))
			end
		elsif obj["Type"] == "presence_change" then
			@s.puts "{\"Kind\":\"Echo\", \"Payload\":{\"user\": \"#{obj["Data"]["user"]}\", \"state\": \"#{obj["Data"]["presence"]}\"}}"
		end	
	end
end

addrs = ENV['CORTANA_ADDR'].split(':')
p = Patcher.new(addrs[0], addrs[1].to_i, ENV['GIT_REPO'], ENV['GIT_EMAIL'])
p.run
