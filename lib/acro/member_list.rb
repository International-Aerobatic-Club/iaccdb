# read CSV (tab delimited) mysql output of member list producd by query,
# mysql <'select given_name, family_name, id, iac_id from members;' >memberlist.txt
require 'CSV'
module ACRO
class MemberList
  FILE_NAME='memberlist.txt'

  def initialize(data_directory)
    member_data_file = File.new(File.join(data_directory, FILE_NAME))
    member_list = CSV.new(member_data_file, headers: true, col_sep: "\t")
    @by_first_last = {}
    @by_fi_li = {}
    @by_f2_l2 = {}
    @by_last = {}
    @by_l2 = {}
    member_list.each do |r|
      index_record(@by_first_last, hash_first_last(r['given_name'], r['family_name']), r)
      index_record(@by_fi_li, hash_fi_li(r['given_name'],r['family_name']), r)
      index_record(@by_f2_l2, hash_f2_l2(r['given_name'],r['family_name']), r)
      index_record(@by_last, hash_last(r['family_name']), r)
      index_record(@by_l2, hash_l2(r['family_name']), r)
    end
  end

  def by_first_last(given_name, family_name)
    return @by_first_last[hash_first_last(given_name, family_name)]
  end

  def by_fi_li(given_name, family_name)
    return @by_fi_li[hash_fi_li(given_name, family_name)]
  end

  def by_f2_l2(given_name, family_name)
    return @by_f2_l2[hash_f2_l2(given_name, family_name)]
  end

  def by_last(family_name)
    return @by_last[hash_last(family_name)]
  end

  def by_l2(family_name)
    return @by_l2[hash_l2(family_name)]
  end

  private

  def index_record(index, key, record)
    index[key] ||= []
    index[key] << record
  end

  def hash_first_last(given_name, family_name)
    given_name ||= ''
    family_name ||= ''
    [given_name.strip.downcase, family_name.strip.downcase].join("\t")
  end

  def hash_fi_li(given_name, family_name)
    given_name ||= ''
    family_name ||= ''
    "#{given_name.strip.downcase[0]}#{family_name.strip.downcase[0]}"
  end

  def hash_f2_l2(given_name, family_name)
    given_name ||= ''
    family_name ||= ''
    "#{given_name.strip.downcase[0,2]}#{family_name.strip.downcase[0,2]}"
  end

  def hash_last(family_name)
    family_name ||= ''
    family_name.strip.downcase
  end

  def hash_l2(family_name)
    family_name ||= ''
    family_name.strip.downcase[0,2]
  end

end
end
