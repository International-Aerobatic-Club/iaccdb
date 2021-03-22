require "test_helper"

class FreeProgramKTest < ActiveSupport::TestCase
  def free_program_k
    @free_program_k ||= FreeProgramK.new
  end

  def test_valid
    assert free_program_k.valid?
  end
end
