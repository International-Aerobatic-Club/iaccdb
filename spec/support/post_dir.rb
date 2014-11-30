require 'fileutils'
# move posts directory out of the way for testing
RSpec.configure do |config|
  post_data_path = DataPost.post_dir
  post_data_hold_path = File.expand_path('../../../posts.test_hold', __FILE__)

  config.before(:suite) do
    FileUtils.mv(post_data_path, post_data_hold_path, force:true)
  end

  config.after(:suite) do
    FileUtils.remove_dir(post_data_path, true)
    FileUtils.mv(post_data_hold_path, post_data_path, force: true)
  end
end
