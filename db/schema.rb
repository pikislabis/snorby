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

ActiveRecord::Schema.define(version: 20160527182126) do

  create_table "agent_asset_names", id: false, force: :cascade do |t|
    t.integer "sensor_sid",    limit: 4, null: false
    t.integer "asset_name_id", limit: 4, null: false
  end

  add_index "agent_asset_names", ["asset_name_id"], name: "index_agent_asset_names_asset_name", using: :btree
  add_index "agent_asset_names", ["sensor_sid"], name: "index_agent_asset_names_sensor", using: :btree

  create_table "aggregated_events", id: false, force: :cascade do |t|
    t.integer "ip_src",           limit: 4, default: 0, null: false
    t.integer "ip_dst",           limit: 4, default: 0, null: false
    t.integer "signature",        limit: 4
    t.integer "event_id",         limit: 4
    t.integer "number_of_events", limit: 8, default: 0, null: false
  end

  create_table "asset_names", force: :cascade do |t|
    t.integer "ip_address", limit: 4,    default: 0,    null: false
    t.string  "name",       limit: 1024,                null: false
    t.boolean "global",                  default: true
  end

  add_index "asset_names", ["ip_address"], name: "index_asset_names_ip_address", using: :btree

  create_table "caches", force: :cascade do |t|
    t.integer  "sid",               limit: 4
    t.integer  "cid",               limit: 4
    t.datetime "ran_at"
    t.integer  "event_count",       limit: 4,        default: 0
    t.integer  "tcp_count",         limit: 4,        default: 0
    t.integer  "udp_count",         limit: 4,        default: 0
    t.integer  "icmp_count",        limit: 4,        default: 0
    t.text     "severity_metrics",  limit: 16777215
    t.text     "signature_metrics", limit: 16777215
    t.text     "src_ips",           limit: 16777215
    t.text     "dst_ips",           limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "caches", ["ran_at"], name: "index_caches_ran_at", using: :btree

  create_table "classifications", force: :cascade do |t|
    t.string  "name",         limit: 50
    t.text    "description",  limit: 65535
    t.integer "hotkey",       limit: 4
    t.boolean "locked",                     default: false
    t.integer "events_count", limit: 4,     default: 0
  end

  add_index "classifications", ["events_count"], name: "index_classifications_events_count", using: :btree
  add_index "classifications", ["hotkey"], name: "index_classifications_hotkey", using: :btree
  add_index "classifications", ["id"], name: "index_classifications_id", using: :btree
  add_index "classifications", ["locked"], name: "index_classifications_locked", using: :btree

  create_table "data", id: false, force: :cascade do |t|
    t.integer "sid",          limit: 4,     null: false
    t.integer "cid",          limit: 4,     null: false
    t.text    "data_payload", limit: 65535
  end

  add_index "data", ["cid"], name: "index_data_cid", using: :btree
  add_index "data", ["sid"], name: "index_data_sid", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0
    t.integer  "attempts",   limit: 4,     default: 0
    t.text     "handler",    limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.text     "locked_by",  limit: 65535
    t.datetime "failed_at"
    t.text     "last_error", limit: 65535
    t.string   "queue",      limit: 255
  end

  add_index "delayed_jobs", ["locked_at"], name: "index_delayed_jobs_locked_at", using: :btree
  add_index "delayed_jobs", ["priority", "run_at"], name: "index_delayed_jobs_run_at_priority", using: :btree

  create_table "detail", primary_key: "detail_type", force: :cascade do |t|
    t.text "detail_text", limit: 65535
  end

  add_index "detail", ["detail_type"], name: "index_detail_detail_type", using: :btree

  create_table "encoding", primary_key: "encoding_type", force: :cascade do |t|
    t.text "encoding_text", limit: 65535
  end

  add_index "encoding", ["encoding_type"], name: "index_encoding_encoding_type", using: :btree

  create_table "event", id: false, force: :cascade do |t|
    t.integer  "sid",               limit: 4, null: false
    t.integer  "cid",               limit: 4, null: false
    t.integer  "signature",         limit: 4
    t.integer  "classification_id", limit: 4
    t.integer  "users_count",       limit: 4, default: 0
    t.integer  "user_id",           limit: 4
    t.integer  "notes_count",       limit: 4, default: 0
    t.integer  "type",              limit: 4, default: 1
    t.integer  "number_of_events",  limit: 4, default: 0
    t.datetime "timestamp"
    t.integer  "id",                limit: 4, null: false
  end

  add_index "event", ["cid"], name: "index_event_cid", using: :btree
  add_index "event", ["classification_id"], name: "index_event_classification_id", using: :btree
  add_index "event", ["id"], name: "index_event_id", using: :btree
  add_index "event", ["notes_count"], name: "index_event_notes_count", using: :btree
  add_index "event", ["sid"], name: "index_event_sid", using: :btree
  add_index "event", ["signature"], name: "index_event_signature", using: :btree
  add_index "event", ["timestamp", "cid", "sid"], name: "index_timestamp_cid_sid", using: :btree
  add_index "event", ["user_id"], name: "index_event_user_id", using: :btree
  add_index "event", ["users_count"], name: "index_event_users_count", using: :btree

  create_table "events_with_join", id: false, force: :cascade do |t|
    t.integer  "sid",               limit: 4,                 null: false
    t.integer  "cid",               limit: 4,                 null: false
    t.integer  "signature",         limit: 4
    t.integer  "classification_id", limit: 4
    t.integer  "users_count",       limit: 4,     default: 0
    t.integer  "user_id",           limit: 4
    t.integer  "notes_count",       limit: 4,     default: 0
    t.integer  "type",              limit: 4,     default: 1
    t.integer  "number_of_events",  limit: 4,     default: 0
    t.datetime "timestamp"
    t.integer  "id",                limit: 4,     default: 0, null: false
    t.integer  "ip_src",            limit: 4,     default: 0, null: false
    t.integer  "ip_dst",            limit: 4,     default: 0, null: false
    t.integer  "sig_priority",      limit: 4
    t.text     "sig_name",          limit: 65535
  end

  create_table "favorites", force: :cascade do |t|
    t.integer "sid",     limit: 4
    t.integer "cid",     limit: 4
    t.integer "user_id", limit: 4
  end

  add_index "favorites", ["cid"], name: "index_favorites_cid", using: :btree
  add_index "favorites", ["id"], name: "index_favorites_id", using: :btree
  add_index "favorites", ["sid"], name: "index_favorites_sid", using: :btree
  add_index "favorites", ["user_id"], name: "index_favorites_user_id", using: :btree

  create_table "icmphdr", id: false, force: :cascade do |t|
    t.integer "sid",       limit: 4, null: false
    t.integer "cid",       limit: 4, null: false
    t.integer "icmp_type", limit: 4
    t.integer "icmp_code", limit: 4
    t.integer "icmp_csum", limit: 4
    t.integer "icmp_id",   limit: 4
    t.integer "icmp_seq",  limit: 4
  end

  add_index "icmphdr", ["cid"], name: "index_icmphdr_cid", using: :btree
  add_index "icmphdr", ["sid"], name: "index_icmphdr_sid", using: :btree

  create_table "iphdr", id: false, force: :cascade do |t|
    t.integer "sid",      limit: 4,             null: false
    t.integer "cid",      limit: 4,             null: false
    t.integer "ip_src",   limit: 4, default: 0, null: false
    t.integer "ip_dst",   limit: 4, default: 0, null: false
    t.integer "ip_ver",   limit: 4, default: 0, null: false
    t.integer "ip_hlen",  limit: 4, default: 0, null: false
    t.integer "ip_tos",   limit: 4, default: 0, null: false
    t.integer "ip_len",   limit: 4, default: 0, null: false
    t.integer "ip_id",    limit: 4, default: 0, null: false
    t.integer "ip_flags", limit: 4, default: 0, null: false
    t.integer "ip_off",   limit: 4, default: 0, null: false
    t.integer "ip_ttl",   limit: 4, default: 0, null: false
    t.integer "ip_proto", limit: 4, default: 0, null: false
    t.integer "ip_csum",  limit: 4, default: 0, null: false
  end

  add_index "iphdr", ["cid"], name: "index_iphdr_cid", using: :btree
  add_index "iphdr", ["ip_dst"], name: "index_iphdr_ip_dst", using: :btree
  add_index "iphdr", ["ip_src"], name: "index_iphdr_ip_src", using: :btree
  add_index "iphdr", ["sid"], name: "index_iphdr_sid", using: :btree

  create_table "lookups", force: :cascade do |t|
    t.string "title", limit: 50
    t.text   "value", limit: 65535
  end

  create_table "notes", force: :cascade do |t|
    t.integer  "sid",        limit: 4
    t.integer  "cid",        limit: 4
    t.integer  "user_id",    limit: 4
    t.text     "body",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["cid"], name: "index_notes_cid", using: :btree
  add_index "notes", ["sid"], name: "index_notes_sid", using: :btree
  add_index "notes", ["user_id"], name: "index_notes_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.text     "description", limit: 65535
    t.integer  "sig_id",      limit: 4
    t.string   "ip_src",      limit: 50
    t.string   "ip_dst",      limit: 50
    t.integer  "user_id",     limit: 4
    t.text     "user_ids",    limit: 16777215
    t.text     "sensor_ids",  limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "opt", id: false, force: :cascade do |t|
    t.integer "sid",       limit: 4,     null: false
    t.integer "cid",       limit: 4,     null: false
    t.integer "optid",     limit: 4,     null: false
    t.integer "opt_proto", limit: 4
    t.integer "opt_code",  limit: 4
    t.integer "opt_len",   limit: 4
    t.text    "opt_data",  limit: 65535
  end

  add_index "opt", ["cid"], name: "index_opt_cid", using: :btree
  add_index "opt", ["optid"], name: "index_opt_optid", using: :btree
  add_index "opt", ["sid"], name: "index_opt_sid", using: :btree

  create_table "reference", primary_key: "ref_id", force: :cascade do |t|
    t.integer "ref_system_id", limit: 4
    t.text    "ref_tag",       limit: 65535
  end

  add_index "reference", ["ref_id"], name: "index_reference_ref_id", using: :btree

  create_table "reference_system", primary_key: "ref_system_id", force: :cascade do |t|
    t.string "ref_system_name", limit: 50
  end

  add_index "reference_system", ["ref_system_id"], name: "index_reference_system_ref_system_id", using: :btree

  create_table "schema", force: :cascade do |t|
    t.integer  "vseq",    limit: 4
    t.datetime "ctime"
    t.string   "version", limit: 50
  end

  add_index "schema", ["id"], name: "index_schema_id", using: :btree

  create_table "search", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "rule_count", limit: 4,        default: 0
    t.boolean  "public",                      default: false
    t.string   "title",      limit: 50
    t.text     "search",     limit: 16777215
    t.text     "checksum",   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search", ["public"], name: "index_search_public", using: :btree
  add_index "search", ["rule_count"], name: "index_search_rule_count", using: :btree
  add_index "search", ["user_id"], name: "index_search_user_id", using: :btree

  create_table "sensor", primary_key: "sid", force: :cascade do |t|
    t.string   "name",           limit: 50,    default: "Click To Change Me"
    t.text     "hostname",       limit: 65535
    t.text     "interface",      limit: 65535
    t.text     "filter",         limit: 65535
    t.integer  "detail",         limit: 4
    t.integer  "encoding",       limit: 4
    t.integer  "last_cid",       limit: 4
    t.boolean  "pending_delete", default: false
    t.datetime "updated_at"
    t.integer  "events_count", limit: 4, default: 0
  end

  add_index "sensor", ["detail"], name: "index_sensor_detail", using: :btree
  add_index "sensor", ["encoding"], name: "index_sensor_encoding", using: :btree
  add_index "sensor", ["events_count"], name: "index_sensor_events_count", using: :btree
  add_index "sensor", ["last_cid"], name: "index_sensor_last_cid", using: :btree
  add_index "sensor", ["sid"], name: "index_sensor_sid", using: :btree

  create_table "settings", primary_key: "name", force: :cascade do |t|
    t.text "value", limit: 16777215
  end

  add_index "settings", ["name"], name: "index_settings_name", using: :btree

  create_table "severities", force: :cascade do |t|
    t.integer "sig_id",       limit: 4
    t.integer "events_count", limit: 4,  default: 0
    t.string  "name",         limit: 50
    t.string  "text_color",   limit: 50, default: "#ffffff"
    t.string  "bg_color",     limit: 50, default: "#dddddd"
  end

  add_index "severities", ["bg_color"], name: "index_severities_bg_color", using: :btree
  add_index "severities", ["events_count"], name: "index_severities_events_count", using: :btree
  add_index "severities", ["id"], name: "index_severities_id", using: :btree
  add_index "severities", ["sig_id"], name: "index_severities_sig_id", using: :btree
  add_index "severities", ["text_color"], name: "index_severities_text_color", using: :btree

  create_table "sig_class", primary_key: "sig_class_id", force: :cascade do |t|
    t.string "sig_class_name", limit: 50
  end

  add_index "sig_class", ["sig_class_id"], name: "index_sig_class_sig_class_id", using: :btree

  create_table "sig_reference", id: false, force: :cascade do |t|
    t.integer "sig_id",  limit: 4, null: false
    t.integer "ref_seq", limit: 4, null: false
    t.integer "ref_id",  limit: 4
  end

  add_index "sig_reference", ["ref_seq"], name: "index_sig_reference_ref_seq", using: :btree
  add_index "sig_reference", ["sig_id"], name: "index_sig_reference_sig_id", using: :btree

  create_table "signature", primary_key: "sig_id", force: :cascade do |t|
    t.integer "sig_class_id", limit: 4
    t.text    "sig_name",     limit: 65535
    t.integer "sig_priority", limit: 4
    t.integer "sig_rev",      limit: 4
    t.integer "sig_sid",      limit: 4
    t.integer "sig_gid",      limit: 4
    t.integer "events_count", limit: 4,     default: 0
  end

  add_index "signature", ["events_count"], name: "index_signature_events_count", using: :btree
  add_index "signature", ["sig_class_id"], name: "index_signature_sig_class_id", using: :btree
  add_index "signature", ["sig_id"], name: "index_signature_sig_id", using: :btree
  add_index "signature", ["sig_priority"], name: "index_signature_sig_priority", using: :btree

  create_table "tcphdr", id: false, force: :cascade do |t|
    t.integer "sid",       limit: 4, null: false
    t.integer "cid",       limit: 4, null: false
    t.integer "tcp_sport", limit: 4
    t.integer "tcp_dport", limit: 4
    t.integer "tcp_seq",   limit: 4
    t.integer "tcp_ack",   limit: 4
    t.integer "tcp_off",   limit: 4
    t.integer "tcp_res",   limit: 4
    t.integer "tcp_flags", limit: 4
    t.integer "tcp_win",   limit: 4
    t.integer "tcp_csum",  limit: 4
    t.integer "tcp_urp",   limit: 4
  end

  add_index "tcphdr", ["cid"], name: "index_tcphdr_cid", using: :btree
  add_index "tcphdr", ["sid"], name: "index_tcphdr_sid", using: :btree
  add_index "tcphdr", ["tcp_dport"], name: "index_tcphdr_tcp_dport", using: :btree
  add_index "tcphdr", ["tcp_sport"], name: "index_tcphdr_tcp_sport", using: :btree

  create_table "udphdr", id: false, force: :cascade do |t|
    t.integer "sid",       limit: 4, null: false
    t.integer "cid",       limit: 4, null: false
    t.integer "udp_sport", limit: 4
    t.integer "udp_dport", limit: 4
    t.integer "udp_len",   limit: 4
    t.integer "udp_csum",  limit: 4
  end

  add_index "udphdr", ["cid"], name: "index_udphdr_cid", using: :btree
  add_index "udphdr", ["sid"], name: "index_udphdr_sid", using: :btree
  add_index "udphdr", ["udp_dport"], name: "index_udphdr_udp_dport", using: :btree
  add_index "udphdr", ["udp_sport"], name: "index_udphdr_udp_sport", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",                    null: false
    t.string   "encrypted_password",     limit: 128, default: "",                    null: false
    t.string   "remember_token",         limit: 255
    t.datetime "remember_created_at"
    t.string   "reset_password_token",   limit: 255
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.integer  "favorites_count",        limit: 4,   default: 0
    t.integer  "accept_notes",           limit: 4,   default: 1
    t.integer  "notes_count",            limit: 4,   default: 0
    t.integer  "per_page_count",         limit: 4,   default: 45
    t.string   "name",                   limit: 50
    t.string   "timezone",               limit: 50,  default: "UTC"
    t.boolean  "admin",                              default: false
    t.boolean  "enabled",                            default: true
    t.boolean  "gravatar",                           default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "online",                             default: false
    t.datetime "last_daily_report_at",               default: '2016-05-16 19:05:48'
    t.integer  "last_weekly_report_at",  limit: 4,   default: 201620
    t.integer  "last_monthly_report_at", limit: 4,   default: 201605
    t.datetime "last_email_report_at"
    t.boolean  "email_reports",                      default: false
  end

  add_index "users", ["favorites_count"], name: "index_users_favorites_count", using: :btree
  add_index "users", ["id"], name: "index_users_id", using: :btree
  add_index "users", ["notes_count"], name: "index_users_notes_count", using: :btree
  add_index "users", ["per_page_count"], name: "index_users_per_page_count", using: :btree

end
