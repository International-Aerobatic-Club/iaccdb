module ACRO
  module AcroDataSetup
    CONTEST_DATA_FILE_PATH = 'spec/acro/contest_data'
    DATA_SAMPLE_FILE_PATH = 'spec/acro/sample_data'

    def contest_data_file(name)
      File.join(CONTEST_DATA_FILE_PATH,name)
    end

    def data_sample_file(name)
      File.join(DATA_SAMPLE_FILE_PATH,name)
    end

    def participant_list_members
      [
        { name: 'Marv Miniski', 
          'id' => 1, 'given_name' => 'Marvin', 'family_name' => 'Minsky', 'iac_id' => 21456 },
        { name: 'Hatch Chaps', 
          'id' => 2, 'given_name' => 'Harry', 'family_name' => 'Chapin', 'iac_id' => 82345 },
        { name: 'Garvy Boy', 
          'id' => 3, 'given_name' => 'Jerry', 'family_name' => 'Garcia', 'iac_id' => 21898 },
        { name: 'Bobby See', 
          'id' => 4, 'given_name' => 'Bob', 'family_name' => 'Seeger', 'iac_id' => 21767 },
        { name: 'Marty Mark', 
          'id' => 5, 'given_name' => 'Mark', 'family_name' => 'Martin', 'iac_id' => 21323 },
        { name: 'Robert Newhart', 
          'given_name' => 'Robert', 'family_name' => 'Newheart', 'iac_id' => 21488 }
      ]
    end

    def create_participant_list
      part_list = ParticipantList::new
      participant_list_members.each do |m|
        part_list.add(m[:name], m)
      end
      part_list
    end

    def setup_contest_extracted_data
      cs = ContestExtractor.new(contest_data_file('newContest.yml'))
      cs.scrape_contest
    end

    def cleanup_contest_extracted_data
      yml_pattern = contest_data_file('*.htm.yml')
      Dir.glob(yml_pattern) do |file|
        FileUtils.rm(file)
      end
    end
  end
end

RSpec.configure do |config|
  include ACRO::AcroDataSetup
  config.include ACRO::AcroDataSetup
  rel_cd_path = File.join('../../..', CONTEST_DATA_FILE_PATH)
  acro_test_path = File.expand_path(rel_cd_path, __FILE__)

  config.before(:suite) do
    part_list = create_participant_list
    part_list.write(acro_test_path)
  end

  config.after(:suite) do
    part_list_file = ACRO::ParticipantList.participant_file_name(acro_test_path)
    File.delete(part_list_file)
  end
end

