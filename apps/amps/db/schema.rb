# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 23) do

  create_table "constructions", :force => true do |t|
    t.integer "s_frame_set_id"
    t.integer "s_morpheme_set_id"
  end

  create_table "e_compositions", :force => true do |t|
    t.integer "s_element_id"
    t.integer "primitive_id"
  end

  create_table "f_compositions", :force => true do |t|
    t.integer "s_frame_set_id"
    t.integer "s_frame_id"
  end

  create_table "frame_sets", :force => true do |t|
    t.text    "form"
    t.integer "sentence_id"
    t.integer "s_frame_set_id"
    t.text    "dot"
  end

  create_table "frames", :force => true do |t|
    t.string  "fid"
    t.string  "form"
    t.string  "relation"
    t.integer "frame_set_id"
    t.integer "s_frame_id"
    t.string  "type"
  end

  create_table "m_compositions", :force => true do |t|
    t.integer "s_morpheme_set_id"
    t.integer "s_morpheme_id"
  end

  create_table "morpheme_sets", :force => true do |t|
    t.text    "form"
    t.text    "phon"
    t.integer "s_morpheme_set_id"
    t.integer "sentence_id"
  end

  create_table "morphemes", :force => true do |t|
    t.string  "form"
    t.string  "phon"
    t.string  "alt"
    t.integer "morpheme_set_id"
    t.integer "s_morpheme_id"
    t.string  "type"
  end

  create_table "p_compositions", :force => true do |t|
    t.integer "morpheme_id"
    t.integer "primitive_id"
  end

  create_table "phrases", :force => true do |t|
    t.string  "form"
    t.integer "s_phrase_id"
    t.string  "type"
  end

  create_table "primitives", :force => true do |t|
    t.string  "form"
    t.string  "color"
    t.string  "form_set"
    t.string  "phon_set"
    t.string  "alt_set"
    t.integer "frame_id"
    t.integer "rprim_id"
    t.integer "dprim_id"
    t.string  "type"
  end

  create_table "r_compositions", :force => true do |t|
    t.integer "primitive_id"
    t.integer "phrase_id"
  end

  create_table "relations", :force => true do |t|
    t.integer "source_id"
    t.integer "target_id"
    t.string  "nature"
    t.integer "s_relation_id"
  end

  create_table "s_elements", :force => true do |t|
    t.string  "form"
    t.integer "primitives_count", :default => 0
    t.string  "cls"
  end

  create_table "s_frame_sets", :force => true do |t|
    t.integer "frame_sets_count", :default => 0
  end

  create_table "s_frames", :force => true do |t|
    t.string  "form"
    t.integer "frames_count", :default => 0
    t.string  "cls"
  end

  create_table "s_morpheme_sets", :force => true do |t|
    t.integer "morpheme_sets_count", :default => 0
  end

  create_table "s_morphemes", :force => true do |t|
    t.string  "form"
    t.integer "morphemes_count", :default => 0
    t.string  "cls"
  end

  create_table "s_phrases", :force => true do |t|
    t.string  "form"
    t.integer "phrases_count", :default => 0
    t.string  "cls"
  end

  create_table "s_relations", :force => true do |t|
    t.string  "nature"
    t.integer "relations_count", :default => 0
  end

  create_table "sentences", :force => true do |t|
    t.integer  "construction_id"
    t.string   "filename"
    t.datetime "created_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

  create_table "wikis", :force => true do |t|
    t.string   "identifier"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body"
  end

end
