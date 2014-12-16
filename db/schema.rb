# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141215015919) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "jobs", force: true do |t|
    t.text    "job_title",        null: false
    t.text    "satisfaction",     null: false
    t.text    "years_experience", null: false
    t.text    "category",         null: false
    t.text    "salary",           null: false
    t.text    "company"
    t.integer "user_id"
  end

  create_table "personalities", force: true do |t|
    t.text    "extraversion",          null: false
    t.text    "agreeableness",         null: false
    t.text    "conscientiousness",     null: false
    t.text    "emotional_stability",   null: false
    t.text    "intellect_imagination", null: false
    t.text    "mbti"
    t.integer "user_id"
  end

  create_table "users", force: true do |t|
    t.text   "username",        null: false
    t.text   "email",           null: false
    t.string "password_digest", null: false
    t.text   "zipcode",         null: false
    t.text   "name"
  end

end
