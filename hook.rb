require 'rubygems'
require 'sinatra'
require 'net/http'
require 'json'

configure do
  set :github_user, ''
  set :github_token, ''
  set :github_url, 'http://github.com/api/v2/yaml/issues/'
end

get '/' do
  "You need to add a post-receive hook for this URL in your github service hooks that will POST to this app. More here: <a href='http://github.com/guides/post-receive-hooks'>Post-receive hooks guide</a>"
end

post '/' do
  payload = JSON.parse(params[:payload])
  /(Kill)(\s+)(\#)(\d+)/.match(payload["commits"][0]["message"])
  issue = Regexp.last_match(4) 
  if issue
    repository = payload['repository']['name']
    url = options.github_url + 'close/' + options.github_user + '/' + repository + '/' + issue
    uri = URI.parse(url)
    req = Net::HTTP::Post.new(uri.path)
    req.set_form_data(:login => options.github_user, :token => options.github_token)
    Net::HTTP.new(uri.host, uri.port).start { |http| http.request(req) }
    "Success!"
  else
    "Failure"
  end
end
