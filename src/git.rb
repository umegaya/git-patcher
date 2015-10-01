class Git 
	LOCAL_PATH="./work"
	def initialize(url, email)
		email = "cortana@superbot.com" unless email
		m = /^(.+?)@(.+)/.match(email)
		if not m then
			raise "invalid email"
		end
		`git config --global user.email "#{email}"`
		`git config --global user.name "#{m[1]}"`
		`git clone #{url} repo` unless File.directory? 'repo'
	end
	def exec(cmd)
		out = `#{cmd}`
		raise "cmd error '#{cmd}'" unless $?.success?
		out
	end
	def process(rec)
		return nil unless rec["attachments"]
		a = rec["attachments"][0]
		m = /<(http.+)>/.match(a["fallback"])
		return nil unless m
		title = a["title"]
		patch_url = m[1]
		url = nil
		Dir.chdir("repo") do
			exec "git reset --hard && git checkout master && git fetch -p && git rebase origin/master"
			work = Time.now.to_i.to_s
			exec "git checkout -b #{work}"
			puts "apply patch from #{patch_url}"
			exec "curl -k -L #{patch_url} | git apply -"
			exec "git commit -a -m \"#{title}\" && git push origin #{work}"
			url = exec "hub pull-request -m \"#{title}\" -b master -h #{work}"
			puts "pull request created at #{url.chop}"
		end
		return {
			"Kind": "Applied",
			"Payload": {
				"url": url,
			}
		}
	rescue => e
		puts "process error:" + e.to_s
		return nil
	end
end
