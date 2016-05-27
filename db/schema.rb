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

ActiveRecord::Schema.define(version: 20160523155343) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "interactions", force: :cascade do |t|
    t.integer  "lgil_code",  null: false
    t.string   "label",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "interactions", ["label"], name: "index_interactions_on_label", unique: true, using: :btree
  add_index "interactions", ["lgil_code"], name: "index_interactions_on_lgil_code", unique: true, using: :btree

  create_table "links", force: :cascade do |t|
    t.integer  "local_authority_id",     null: false
    t.integer  "service_interaction_id", null: false
    t.string   "url",                    null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "links", ["local_authority_id", "service_interaction_id"], name: "index_links_on_local_authority_id_and_service_interaction_id", unique: true, using: :btree
  add_index "links", ["local_authority_id"], name: "index_links_on_local_authority_id", using: :btree
  add_index "links", ["service_interaction_id"], name: "index_links_on_service_interaction_id", using: :btree

  create_table "local_authorities", force: :cascade do |t|
    t.string   "gss"
    t.string   "homepage_url"
    t.string   "name"
    t.string   "slug"
    t.string   "snac"
    t.string   "tier"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "local_authorities", ["gss"], name: "index_local_authorities_on_gss", unique: true, using: :btree
  add_index "local_authorities", ["snac"], name: "index_local_authorities_on_snac", unique: true, using: :btree

  create_table "service_interactions", force: :cascade do |t|
    t.integer  "service_id"
    t.integer  "interaction_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "service_interactions", ["service_id", "interaction_id"], name: "index_service_interactions_on_service_id_and_interaction_id", unique: true, using: :btree

  create_table "services", force: :cascade do |t|
    t.integer  "lgsl_code",                  null: false
    t.string   "label",                      null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "tier"
    t.string   "slug",                       null: false
    t.boolean  "enabled",    default: false, null: false
  end

  add_index "services", ["label"], name: "index_services_on_label", unique: true, using: :btree
  add_index "services", ["lgsl_code"], name: "index_services_on_lgsl_code", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "uid"
    t.string   "organisation_slug"
    t.string   "organisation_content_id"
    t.text     "permissions"
    t.boolean  "remotely_signed_out",     default: false
    t.boolean  "disabled",                default: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_foreign_key "links", "local_authorities"
  add_foreign_key "links", "service_interactions"
  add_foreign_key "service_interactions", "interactions"
  add_foreign_key "service_interactions", "services"
end
