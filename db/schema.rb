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

ActiveRecord::Schema.define(version: 20140112212040) do

  create_table "commits", force: true do |t|
    t.integer  "repo_id"
    t.integer  "user_id"
    t.string   "sha"
    t.string   "message"
    t.date     "date_created"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commits", ["repo_id"], name: "index_commits_on_repo_id"
  add_index "commits", ["user_id"], name: "index_commits_on_user_id"

  create_table "companies", force: true do |t|
    t.string   "name"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "github_load_msgs", force: true do |t|
    t.integer  "github_load_id"
    t.string   "msg"
    t.integer  "log_level"
    t.datetime "log_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "github_load_msgs", ["github_load_id"], name: "index_github_load_msgs_on_github_load_id"

  create_table "github_loads", force: true do |t|
    t.datetime "load_start_time"
    t.datetime "load_complete_time"
    t.boolean  "initial_load"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pull_requests", force: true do |t|
    t.integer  "repo_id"
    t.integer  "user_id"
    t.integer  "git_id"
    t.integer  "pr_number"
    t.text     "body"
    t.string   "title"
    t.string   "state"
    t.date     "date_created"
    t.date     "date_closed"
    t.date     "date_updated"
    t.date     "date_merged"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pull_requests", ["repo_id"], name: "index_pull_requests_on_repo_id"
  add_index "pull_requests", ["user_id"], name: "index_pull_requests_on_user_id"

  create_table "repos", force: true do |t|
    t.integer  "git_id"
    t.string   "name"
    t.string   "full_name"
    t.boolean  "fork"
    t.date     "date_created"
    t.date     "date_updated"
    t.date     "date_pushed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.integer  "company_id"
    t.integer  "git_id"
    t.string   "login"
    t.string   "name"
    t.string   "location"
    t.string   "email"
    t.date     "date_created"
    t.date     "date_updated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["company_id"], name: "index_users_on_company_id"

end
