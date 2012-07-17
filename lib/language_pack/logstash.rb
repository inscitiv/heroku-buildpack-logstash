require "language_pack"
require "language_pack/ruby"

# Rack Language Pack. This is for any non-Rails Rack apps like Sinatra.
class LanguagePack::Logstash < LanguagePack::Ruby

  # detects if this is a valid Rack app by seeing if "config.ru" exists
  # @return [Boolean] true if it's a Rack app
  def self.use?
    File.exist?("logstash.conf")
  end

  def ruby_version
    "ruby-1.9.3"
  end

  def name
    "Ruby/Logstash"
  end

  def default_process_types
    {
      "worker"  => "bundle exec bin/logstash agent -c logstash.conf",
      "console" => "bundle exec irb"
    }
  end

  def compile
    Dir.chdir(build_path)
    remove_vendor_bundle
    install_ruby
    install_jvm
    setup_language_pack_environment
    allow_git do
      fetch_logstash
      install_language_pack_gems
      build_bundler
      create_database_yml
      install_binaries
      run_assets_precompile_rake_task
    end
  end

  # Add a redis2go instance
  def default_addons
    add_shared_database_addon + [ "redistogo:nano" ]
  end

  protected
  
  def fetch_logstash
    log("fetch logstash") do
      run("git clone --depth 1 https://github.com/logstash/logstash.git .")
      log("fetch logstash", Dir['*'].sort.join("\n"))
    end
  end
  
end

