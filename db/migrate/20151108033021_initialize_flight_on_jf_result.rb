class InitializeFlightOnJfResult < ActiveRecord::Migration
  def up
    JfResult.all.each do |jf_result|
      jf_result.flight_id = jf_result.f_result.flight_id
      jf_result.save
    end
  end
  def down
  end
end
