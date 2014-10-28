# Copyright (c) 2011, 2012, 2013, 2014 Solano Labs All Rights Reserved

Given /^the command is "([^"]*)"$/ do |command|
  @command = command
end

When /^I respond to "([^"]*)" with "([^"]*)"$/ do |str, response|
  cmd = @command || "solano suite"
  get_process(cmd).expect(str, response)
  puts "matched #{str} and wrote #{response}"
end

Given /^a solano global config file exists$/ do
  file_to_write = solano_global_config_file_path
end
