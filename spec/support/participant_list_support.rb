module ACRO
module ParticipantListTest
  def participant_list_members
    [
      { name: 'Marv Miniski', 
        'id' => 1, 'given_name' => 'Marvin', 'family_name' => 'Minsky', 'iac_id' => 21456 },
      { name: 'Hatch Chaps', 
        'id' => 2, 'given_name' => 'Harry', 'family_name' => 'Chapin', 'iac_id' => 82345 },
      { name: 'Garvy Boy', 
        'id' => 3, 'given_name' => 'Jerry', 'family_name' => 'Garcia', 'iac_id' => 21456 },
      { name: 'Bobby See', 
        'id' => 4, 'given_name' => 'Bob', 'family_name' => 'Seeger', 'iac_id' => 21456 },
      { name: 'Marty Mark', 
        'id' => 5, 'given_name' => 'Mark', 'family_name' => 'Martin', 'iac_id' => 21456 }
    ]
  end

  def create_participant_list
    part_list = ACRO::ParticipantList::new
    participant_list_members.each do |m|
      part_list.add(m[:name], m)
    end
    part_list
  end
end
end

RSpec.configure do |config|
  include ACRO::ParticipantListTest
  config.include ACRO::ParticipantListTest
  acro_test_path = File.expand_path('../../../spec/acro', __FILE__)
  part_list_file = File.join(acro_test_path, ACRO::ParticipantList::LIST_NAME)

  config.before(:suite) do
    part_list = create_participant_list
    part_list.write(acro_test_path)
  end

  config.after(:suite) do
    File.delete(part_list_file)
  end
end
