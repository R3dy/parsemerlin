#!/usr/bin/env ruby
begin
  require 'pry'
  require 'date'
  require 'json'
  require 'optparse'
  require 'net/https'
  require 'base64'
  require 'uri'
rescue LoadError => dependencieserr
  puts "[ERROR] it didn't work bro! - " + dependencieserr.message.chomp
  exit!
end

COMMANDS = []
PARSED = []
opts = {}
args = OptionParser.new do |opt|
  opt.banner = "parsemerlin version: 0.1 - updated: 04/26/2022\r\n\r\n"
  opt.on("-f", "--file [File Path]", "\tThe agent log file you want to parse") { |file| opts[:file] = File.open(file).read.encode("UTF-8", invalid: :replace, replace: "")}
  opt.on("-i", "--id [String]", "\tAgent ID") { |id| opts[:agentid] = id }
  opt.on("-t", "--target [String]", "\tTarget server to POST results") { |host| opts[:host] = host }
  opt.on("-e", "--endpoint [String]", "\tEndpoint on target server") { |endpoint| opts[:endpoint] = endpoint }
  opt.on("-a", "--auth [String]", "\tUserame:Password for basic authenticaiton") { |auth| opts[:auth] = auth }
  opt.on("-v", "--verbose", "\tEnabled verbose output\r\n\r\n") { |v| opts[:verbose] = true }
end

begin
  args.parse(ARGV)
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  exit!
end


def parsecommandline(line)
  begin
    datetime = line.split('[')[1].split(']')[0]
    jobid = line.split('ID:')[1].split(',')[0]
    command = line.split('Args:[')[1].split(']')[0]
    return {datetime: DateTime.parse(datetime).to_time.to_s, jobid: jobid, command: command}
  rescue => errr
    puts "[ERROR] prasecommandline didn't work bro! - " + errr.message.chomp + "\r\n" + line if v
  end
end


def parseoutput(blob, v)
  begin
    jobid = blob.split(': ')[1].split[0]
    output = blob.split('stdout')[1].split('):')[1].split('[20')[0]
    command = COMMANDS.select { |command| command[:jobid] == jobid }[0]
    command[:output] = '```' + output + '```'
    return command
  rescue => errr
    puts "[ERROR] praseoutput didn't work bro! - " + errr.message.chomp + "\r\n" + blob if v
  end
end

def reportcommand(command, opts)
  begin
    basicauth = Base64.encode64(opts[:auth])
    uri = URI.parse("https://#{opts[:host]}#{opts[:endpoint]}")
    header = {"Content-Type": "application/json", "Authorization": "Basic #{basicauth}"}
    command[:agentid] = opts[:agentid]

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.port == 443
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = command.to_json
    response = http.request(request)
  rescue => errr
    puts "[ERROR] reportcommand didn't work bro! - " + errr.message.chomp + "\r\n" + blob if v
  end
end

def doit(opts)
  opts[:file].split("\n") do |line|
    if line.include? "Created job"
      parsed = parsecommandline(line)
      COMMANDS << parsed
    end
  end
  opts[:file].split("Results for job") do |result|
    if result.split(': ')[1].split[0].size == 10
      parsed  = parseoutput(result, opts[:verbose])
      PARSED << parsed
    end
  end
  PARSED.each do |command| 
      reportcommand(command, opts)
  end
end

doit(opts)
