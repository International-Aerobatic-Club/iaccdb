module ACRO

# The Control file YAML format
#---
#contestName: 'U.S. National Aerobatic Championships'
#startDate: '2014-09-21'
#city: 'Sherman and Denison'
#state: 'TX'
#director: 'Gray Brandt'
#region : 'National'
#chapter : 'IAC'
#contest_id : 0
class ControlFile
  PARTICIPANT_FILE_NAME = 'participant_mapping.yml'
  attr_reader :data_directory 

  def initialize(control_file)
    @control_data = YAML.load_file(control_file)
    @data_directory = Dir.new(File.dirname(control_file))
  end

  def name
    check_data(@control_data, 'contestName')
  end

  def start_date
    check_data(@control_data, 'startDate')
  end

  def city
    check_data(@control_data, 'city')
  end

  def state
    check_data(@control_data, 'state')
  end

  def director
    check_data(@control_data, 'director')
  end

  # can return nil
  def chapter
    @control_data['chapter']
  end

  # returns 'National' if not specified
  def region
    @control_data['region'] || 'National'
  end

  def contest_id
    check_data(@control_data, 'contest_id')
  end

  # ACRO pilot_flight result file name format
  def pilot_flight_result_files
    pfs = self.data_directory.find_all { |name| name =~ /^pilot_p\d{3}s\d\d\.htm\.yml$/ }
    pfs.collect { |fn| File.join(self.data_directory.path, fn) }
  end

  # ACRO multi_flight results file name format
  def category_result_files
    crs = self.data_directory.find_all { |name| name =~ /^multi_.*\.htm\.yml$/ }
    crs.collect { |fn| File.join(self.data_directory.path, fn) }
  end

  # name of file with mapping from participant name to member record identifier
  def participant_to_member_id_file_name
    File.join(self.data_directory.path, PARTICIPANT_FILE_NAME)
  end

  private

  def check_data(control_data, field)
    datum = control_data[field]
    if !datum
      raise ArgumentError, "Missing data for contest #{field}"
    end
    datum
  end

end
end
