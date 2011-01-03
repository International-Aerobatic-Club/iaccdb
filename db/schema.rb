# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110103164012) do

  create_table "contests", :force => true do |t|
    t.string   "name",       :limit => 48
    t.string   "city",       :limit => 24
    t.string   "state",      :limit => 2
    t.date     "start"
    t.integer  "chapter"
    t.string   "director",   :limit => 48
    t.string   "region",     :limit => 16
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flights", :force => true do |t|
    t.integer  "contest_id",               :null => false
    t.string   "category",   :limit => 16, :null => false
    t.string   "name",       :limit => 16, :null => false
    t.integer  "sequence",                 :null => false
    t.integer  "chief_id"
    t.integer  "assist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "aircat",     :limit => 1
  end

  create_table "judges", :force => true do |t|
    t.integer  "judge_id"
    t.integer  "assist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manny_synches", :force => true do |t|
    t.integer  "contest_id"
    t.integer  "manny_number"
    t.datetime "synch_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", :force => true do |t|
    t.integer  "iac_id"
    t.string   "given_name",  :limit => 40
    t.string   "family_name", :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pilot_flights", :force => true do |t|
    t.integer  "pilot_id"
    t.integer  "flight_id"
    t.integer  "sequence_id"
    t.integer  "aircraft_id"
    t.string   "chapter",     :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
