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

ActiveRecord::Schema.define(version: 20160515174910) do

  create_table "airsearches", force: :cascade do |t|
    t.string   "user"
    t.string   "client"
    t.string   "type_client"
    t.string   "phone"
    t.integer  "q1"
    t.integer  "q2"
    t.integer  "q3"
    t.integer  "q4"
    t.integer  "q5"
    t.integer  "q6"
    t.integer  "q7"
    t.integer  "q8"
    t.integer  "q9"
    t.integer  "q10"
    t.integer  "q11"
    t.integer  "q12"
    t.decimal  "cotation_value"
    t.string   "status"
    t.string   "reason"
    t.string   "pains"
    t.string   "solution_applied"
    t.string   "schedule"
    t.string   "obs"
    t.string   "finished"
    t.integer  "user_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "airsearches", ["user_id"], name: "index_airsearches_on_user_id", using: :btree

  create_table "answers", force: :cascade do |t|
    t.string   "description"
    t.integer  "score"
    t.integer  "question_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.string   "link"
    t.decimal  "r1"
    t.decimal  "r2"
    t.decimal  "r3"
    t.decimal  "r4"
    t.decimal  "r5"
    t.decimal  "r6"
    t.integer  "qnt_question"
    t.integer  "position"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "clients", force: :cascade do |t|
    t.string   "name"
    t.string   "cellphone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "conversations", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "conversations", ["recipient_id"], name: "index_conversations_on_recipient_id", using: :btree
  add_index "conversations", ["sender_id"], name: "index_conversations_on_sender_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.integer  "owner"
    t.string   "filename"
    t.string   "content_type"
    t.binary   "file_contents"
    t.string   "type_research"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "expire_dates", force: :cascade do |t|
    t.date     "date_expire"
    t.boolean  "active"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "loginfos", force: :cascade do |t|
    t.string   "employee"
    t.string   "task"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meessages", force: :cascade do |t|
    t.text     "body"
    t.integer  "conversation_id"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "meessages", ["conversation_id"], name: "index_meessages_on_conversation_id", using: :btree
  add_index "meessages", ["user_id"], name: "index_meessages_on_user_id", using: :btree

  create_table "meetings", force: :cascade do |t|
    t.string   "client"
    t.string   "phone"
    t.decimal  "cotation_value"
    t.string   "status"
    t.string   "type_client"
    t.date     "start_time"
    t.integer  "clerk_id"
    t.string   "research_path"
    t.integer  "research_id"
    t.string   "obs"
    t.string   "clerk_name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messengers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "packsearches", force: :cascade do |t|
    t.string   "user"
    t.string   "client"
    t.string   "type_client"
    t.string   "phone"
    t.integer  "q1"
    t.integer  "q2"
    t.integer  "q3"
    t.integer  "q4"
    t.integer  "q5"
    t.integer  "q6"
    t.integer  "q7"
    t.integer  "q8"
    t.integer  "q9"
    t.integer  "q10"
    t.integer  "q11"
    t.integer  "q12"
    t.integer  "q13"
    t.decimal  "cotation_value"
    t.string   "status"
    t.string   "reason"
    t.string   "pains"
    t.string   "solution_applied"
    t.string   "schedule"
    t.string   "obs"
    t.string   "finished"
    t.integer  "user_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "packsearches", ["user_id"], name: "index_packsearches_on_user_id", using: :btree

  create_table "questions", force: :cascade do |t|
    t.integer  "category_id"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "questions", ["category_id"], name: "index_questions_on_category_id", using: :btree

  create_table "rodosearches", force: :cascade do |t|
    t.string   "user"
    t.string   "client"
    t.string   "type_client"
    t.string   "phone"
    t.integer  "q1"
    t.integer  "q2"
    t.integer  "q3"
    t.integer  "q4"
    t.integer  "q5"
    t.integer  "q6"
    t.decimal  "cotation_value"
    t.string   "status"
    t.string   "reason"
    t.string   "pains"
    t.string   "solution_applied"
    t.string   "schedule"
    t.string   "obs"
    t.string   "finished"
    t.integer  "user_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "rodosearches", ["user_id"], name: "index_rodosearches_on_user_id", using: :btree

  create_table "solutions", force: :cascade do |t|
    t.integer  "answer_id"
    t.string   "description"
    t.string   "category_name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "solutions", ["answer_id"], name: "index_solutions_on_answer_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "type_access"
    t.boolean  "ccategory"
    t.boolean  "cresearch"
    t.boolean  "cquestion"
    t.boolean  "cadvice"
    t.boolean  "cuser"
    t.boolean  "mupload"
    t.boolean  "rfecha"
    t.boolean  "minput"
    t.boolean  "mcli"
    t.boolean  "rbusiness"
    t.boolean  "ccli"
    t.boolean  "mmeeting"
    t.boolean  "ranalitic"
    t.boolean  "mlog"
    t.decimal  "goal"
    t.integer  "qnt_research"
    t.decimal  "total_sale"
    t.decimal  "current_percent"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.boolean  "rpen"
    t.boolean  "rmark"
    t.boolean  "rsales"
  end

  add_foreign_key "airsearches", "users"
  add_foreign_key "answers", "questions"
  add_foreign_key "meessages", "conversations"
  add_foreign_key "meessages", "users"
  add_foreign_key "packsearches", "users"
  add_foreign_key "questions", "categories"
  add_foreign_key "rodosearches", "users"
  add_foreign_key "solutions", "answers"
end
