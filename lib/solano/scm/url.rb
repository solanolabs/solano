# Copyright (c) 2011-2015 Solano Labs All Rights Reserved

require 'addressable/uri'

module Solano
  class SCM
    def self.parse_scp_url(url, scp_path)
      # remove the ssh scheme (if any)
      url_to_parse = without_scheme(url, "ssh")

      # This is a gross abuse of Adressable::URI
      # It will treat git@github.com in git@github.com:user/repo.git as a scheme
      uri = Addressable::URI.parse(url_to_parse)
      raise SolanoError.new("invalid repo url #{url}") if uri.scheme.nil?

      scheme_parts = uri.scheme.split("@")
      uri.path = "/#{uri.path}" unless uri.path.to_s[0] == "/"
      uri.scheme = "ssh"
      uri.host = scheme_parts.last
      uri.user = scheme_parts.first
      uri
    end

    # Returns scp path if it looks like this is an SCP url
    def self.scp_url?(raw_url, attempted_parse)
      if attempted_parse && attempted_parse.scheme == 'https' then
        return nil
      end
      raw_url_elements = without_scheme(raw_url).split(":")
      scp_path = raw_url_elements.last if raw_url_elements.size > 1
      if scp_path then
        path_elements = scp_path.split(/\//)
        return scp_path if path_elements[0] !~ /^\d+$/
      end
      return nil
    end

    def self.without_scheme(url, scheme = nil)
      scheme ||= "[a-z]+"
      url.gsub(/^#{scheme}\:\/\//, "")
    end

    # Weak validator; server will also validate
    def self.valid_repo_url?(url)
      if url.nil? || url.strip.empty? then
        raise SolanoError.new("invalid empty scm url")
      end

      begin
        attempted_parse = Addressable::URI.parse(url)
      rescue Exception => e
        raise SolanoError.new(e.message)
      end

      if scp_path = scp_url?(url, attempted_parse) then
        uri = parse_scp_url(url, scp_path)
      else
        uri = attempted_parse
      end

      scheme_pattern = SCMS+SCMS.map { |scm| scm+"+ssh" }
      scheme_pattern = scheme_pattern.join("|")
      scheme_pattern = "https?|ssh|"+scheme_pattern

      ok =  uri.scheme =~ /^(#{scheme_pattern})$/
      ok &&= uri.host.size > 0
      ok &&= uri.path.size > 0

      if !ok then
        raise SolanoError.new("invalid repo url: '#{url}'")
      end
      return ok
    end
  end
end
