# Copyright (c) 2012, 2013, 2014, 2015 Solano Labs, Inc. All Rights Reserved

require 'stringio'

class String
  def sanitize(encoding="UTF-8")
    opts = {:invalid => :replace, :undef => :replace}
    d = self.dup
    d.force_encoding(encoding).valid_encoding? ?
      d : d.force_encoding("BINARY").encode(encoding, opts)
  end

  def sanitize!(encoding="UTF-8")
    opts = {:invalid => :replace, :undef => :replace}
    unless self.force_encoding(encoding).valid_encoding?
      self.force_encoding("BINARY")
      self.encode!(encoding, opts)
    end
  end
end

module Solano
  def self.message_pack(value)
    io = StringIO.new
    if RUBY_VERSION =~ /^1[.]([0-8]|9[.][0-2])/ then
      io.set_encoding("UTF-8")
    else
      io.set_encoding("UTF-8", "UTF-8")
    end
    packer = ::MessagePackPure::Packer.new(io)
    packer.write(value)
    result = io.string
    return result
  end
end

module ConfigHelper
  def hash_stringify_keys(h)
    case h
    when Hash
      Hash[ h.map { |k, v| [ k.to_s, hash_stringify_keys(v) ] } ]
    when Enumerable
      h.map { |v| hash_stringify_keys(v) }
    else
      h
    end
  end
end
