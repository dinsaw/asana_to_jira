require 'net/http'
require 'json'

class JSONAPIFacade
	def self.call(req, uri)
		res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') { |http|
		  http.request(req)
		}
		JSON.parse(res.body)
	end
end