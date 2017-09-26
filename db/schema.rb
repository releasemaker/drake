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

ActiveRecord::Schema.define(version: 20170926135212) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "repo_memberships", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "repo_id"
    t.boolean "write"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repo_id"], name: "index_repo_memberships_on_repo_id"
    t.index ["user_id", "repo_id"], name: "index_repo_memberships_on_user_id_and_repo_id", unique: true
    t.index ["user_id"], name: "index_repo_memberships_on_user_id"
  end

  create_table "repos", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.boolean "enabled"
    t.string "provider_uid_or_url"
    t.json "provider_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type", "provider_uid_or_url"], name: "index_repos_on_type_and_provider_uid_or_url", unique: true
  end

  create_table "user_identities", force: :cascade do |t|
    t.bigint "user_id"
    t.string "provider"
    t.string "uid"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "uid"], name: "index_user_identities_on_provider_and_uid", unique: true
    t.index ["user_id", "provider"], name: "index_user_identities_on_user_id_and_provider", unique: true
    t.index ["user_id"], name: "index_user_identities_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "super_admin", default: false
    t.string "email"
    t.string "name"
    t.string "crypted_password"
    t.string "salt"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "repo_memberships", "repos"
  add_foreign_key "repo_memberships", "users"
  add_foreign_key "user_identities", "users"
end
