RSpec.describe NoticeFeeder do
  it "has a version number" do
    expect(NoticeFeeder::VERSION).not_to be nil
  end

  it "valid sample data" do
    data_path = File.join(__dir__, "assets", "*.yaml")
    expect(NoticeFeeder.validate(data_file_path: data_path)).to be 0 # success
  end
end
