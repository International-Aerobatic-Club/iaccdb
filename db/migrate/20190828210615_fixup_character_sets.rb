class FixupCharacterSets < ActiveRecord::Migration[5.1]
  reversible do |dir|
    dir.up do
      query = <<~SQL
  ALTER TABLE `airplanes` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `categories` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `contests` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `data_posts` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `delayed_jobs` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `failures` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `flights` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `jc_results` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `jf_results` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `judges` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `jy_results` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `make_models` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `manny_synches` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `members` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `pc_results` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `pf_results` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `pfj_results` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `pilot_flights` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `region_contests` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `regional_pilots` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `result_accums` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `result_members` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `results` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `scores` CONVERT TO CHARACTER SET `utf8mb4`;
  ALTER TABLE `sequences` CONVERT TO CHARACTER SET `utf8mb4`;
      SQL
      query.each_line { |line| exec_query(line) }
    end

    dir.down do
      query = <<~SQL
  ALTER TABLE `airplanes` CONVERT TO CHARACTER SET `latin1`;
  ALTER TABLE `categories` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `contests` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `data_posts` CONVERT TO CHARACTER SET `latin1`;
  ALTER TABLE `delayed_jobs` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `failures` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `flights` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `jc_results` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `jf_results` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `judges` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `jy_results` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `make_models` CONVERT TO CHARACTER SET `latin1`;
  ALTER TABLE `manny_synches` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `members` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `pc_results` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `pf_results` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `pfj_results` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `pilot_flights` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `region_contests` CONVERT TO CHARACTER SET `latin1`;
  ALTER TABLE `regional_pilots` CONVERT TO CHARACTER SET `latin1`;
  ALTER TABLE `result_accums` CONVERT TO CHARACTER SET `latin1`;
  ALTER TABLE `result_members` CONVERT TO CHARACTER SET `latin1`;
  ALTER TABLE `results` CONVERT TO CHARACTER SET `latin1`;
  ALTER TABLE `scores` CONVERT TO CHARACTER SET `utf8`;
  ALTER TABLE `sequences` CONVERT TO CHARACTER SET `utf8`;
      SQL
      query.each_line { |line| exec_query(line) }
    end
  end
end
