require "yaml"
require "json"
require "json-schema"
require "dotenv"
require "tempfile"
require "google-cloud-storage"
require "notice_feeder/version"

module NoticeFeeder
  class Error < StandardError; end

  def self.validate
    schema = YAML.load_file(File.join(__dir__, "..", "schema", "data.yaml"))

    success = true
    data_file_paths = Dir.glob(File.join(Dir.pwd, "data", "*.yaml"))
    data_file_paths.each do |path|
      begin
        data = YAML.load_file(path)
        JSON::Validator.validate!(schema, data)
      rescue e
        success = false
        puts e.messages
      end
    end

    if success
      puts 'validation: ok'
      return 0
    else
      puts 'validation: error'
      return 1
    end
  end

  def self.update
    # env
    Dotenv.load

    # join data
    files = Dir.glob(File.join(Dir.pwd, "data", "*.yaml"))

    ground_data = files.map do |path|
      YAML.load_file(path)
    end
    .reduce([]) do |mono, item|
      mono << item
    end

    # compose notice data
    composend = {
      updated_at: Time.now.to_i,
      data: ground_data
    }
    temp = Tempfile.new
    temp.puts composend.to_json

    # upload Google Storage
    storage = Google::Cloud::Storage.new(
      project_id: ENV["PROJECT_ID"],
      credentials: ENV["KEYFILE"]
    )
    bucket = storage.bucket(ENV["BUCKET"])
    bucket.create_file temp, "notice.json"


    puts "update: ok"
    return 0

  ensure
    temp&.close
  end
end
