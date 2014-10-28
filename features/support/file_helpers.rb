# Copyright (c) 2011, 2012, 2013, 2014 Solano Labs All Rights Reserved

module FileHelpers
  def solano_global_config_file_path
    File.join(ENV["HOME"], ".solano.localhost")
  end

  def solano_homedir_path
    File.join(Dir.tmpdir, "solano-aruba", "tmphome")
  end
end

World(FileHelpers)
