class RenameJudgeIdColumns < ActiveRecord::Migration
  def self.up
    rename_column :judges, :judge, :judge_id
    rename_column :judges, :assist, :assist_id
  end

  def self.down
    rename_column :judges, :judge_id, :judge
    rename_column :judges, :assist_id, :assist
  end
end
