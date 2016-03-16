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

ActiveRecord::Schema.define(version: 20160308102522) do

  create_table "adjustments", force: :cascade do |t|
    t.integer  "loan_id",          limit: 4,                     null: false
    t.integer  "amount",           limit: 4,                     null: false
    t.date     "date",                                           null: false
    t.text     "notes",            limit: 65535
    t.integer  "created_by_id",    limit: 4,                     null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "post_claim_limit",               default: false, null: false
    t.string   "type",             limit: 255,                   null: false
  end

  add_index "adjustments", ["created_by_id"], name: "index_adjustments_on_created_by_id", using: :btree
  add_index "adjustments", ["date"], name: "index_adjustments_on_date", using: :btree
  add_index "adjustments", ["loan_id", "date"], name: "index_adjustments_on_loan_id_and_date", using: :btree
  add_index "adjustments", ["loan_id"], name: "index_adjustments_on_loan_id", using: :btree
  add_index "adjustments", ["type"], name: "index_adjustments_on_type", using: :btree

  create_table "admin_audits", force: :cascade do |t|
    t.string   "auditable_type",        limit: 255, null: false
    t.integer  "auditable_id",          limit: 4,   null: false
    t.integer  "modified_by_id",        limit: 4,   null: false
    t.date     "modified_on",                       null: false
    t.string   "action",                limit: 255, null: false
    t.integer  "legacy_id",             limit: 4
    t.string   "legacy_object_id",      limit: 255
    t.string   "legacy_object_type",    limit: 255
    t.integer  "legacy_object_version", limit: 4
    t.string   "legacy_modified_by",    limit: 255
    t.string   "ar_timestamp",          limit: 255
    t.string   "ar_insert_timestamp",   limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "data_corrections", force: :cascade do |t|
    t.integer  "loan_id",                            limit: 4,                 null: false
    t.integer  "created_by_id",                      limit: 4,                 null: false
    t.string   "change_type_id",                     limit: 255,               null: false
    t.string   "oid",                                limit: 255
    t.integer  "seq",                                limit: 4,     default: 0, null: false
    t.date     "date_of_change",                                               null: false
    t.date     "modified_date",                                                null: false
    t.string   "modified_user",                      limit: 255
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.text     "data_correction_changes",            limit: 65535
    t.string   "_legacy_business_name",              limit: 255
    t.string   "_legacy_old_business_name",          limit: 255
    t.date     "_legacy_facility_letter_date"
    t.date     "_legacy_old_facility_letter_date"
    t.string   "_legacy_sortcode",                   limit: 255
    t.string   "_legacy_old_sortcode",               limit: 255
    t.integer  "_legacy_dti_demand_outstanding",     limit: 8
    t.integer  "_legacy_old_dti_demand_outstanding", limit: 8
    t.integer  "_legacy_dti_interest",               limit: 8
    t.integer  "_legacy_old_dti_interest",           limit: 8
    t.integer  "_legacy_lending_limit_id",           limit: 4
    t.integer  "_legacy_old_lending_limit_id",       limit: 4
    t.string   "_legacy_postcode",                   limit: 255
    t.string   "_legacy_old_postcode",               limit: 255
    t.string   "_legacy_lender_reference",           limit: 255
    t.string   "_legacy_old_lender_reference",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "data_corrections", ["loan_id", "seq"], name: "index_data_corrections_on_loan_id_and_seq", unique: true, using: :btree

  create_table "data_migration_records", force: :cascade do |t|
    t.string   "version",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "data_migration_records", ["version"], name: "index_data_migration_records_on_version", unique: true, using: :btree

  create_table "ded_codes", force: :cascade do |t|
    t.string   "legacy_id",            limit: 255
    t.string   "group_description",    limit: 255
    t.string   "category_description", limit: 255
    t.string   "code",                 limit: 255
    t.string   "code_description",     limit: 255
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "ded_codes", ["code"], name: "index_ded_codes_on_code", unique: true, using: :btree

  create_table "demand_to_borrowers", force: :cascade do |t|
    t.integer  "loan_id",             limit: 4,   null: false
    t.integer  "seq",                 limit: 4,   null: false
    t.integer  "created_by_id",       limit: 4,   null: false
    t.date     "date_of_demand",                  null: false
    t.integer  "demanded_amount",     limit: 8,   null: false
    t.date     "modified_date",                   null: false
    t.integer  "legacy_loan_id",      limit: 4
    t.string   "legacy_created_by",   limit: 255
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "demand_to_borrowers", ["loan_id", "seq"], name: "index_demand_to_borrowers_on_loan_id_and_seq", unique: true, using: :btree

  create_table "experts", force: :cascade do |t|
    t.integer  "lender_id",  limit: 4, null: false
    t.integer  "user_id",    limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "experts", ["lender_id"], name: "index_experts_on_lender_id", using: :btree
  add_index "experts", ["user_id"], name: "index_experts_on_user_id", unique: true, using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "lender_id",              limit: 4,               null: false
    t.string   "reference",              limit: 255,             null: false
    t.string   "period_covered_quarter", limit: 255,             null: false
    t.string   "period_covered_year",    limit: 255,             null: false
    t.date     "received_on",                                    null: false
    t.integer  "created_by_id",          limit: 4,               null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "legacy_id",              limit: 4
    t.integer  "version",                limit: 4,   default: 0, null: false
    t.integer  "legacy_lender_oid",      limit: 4
    t.string   "xref",                   limit: 255,             null: false
    t.string   "period_covered_to_date", limit: 255
    t.string   "created_by_legacy_id",   limit: 255
    t.string   "creation_time",          limit: 255
    t.string   "ar_timestamp",           limit: 255
    t.string   "ar_insert_timestamp",    limit: 255
  end

  add_index "invoices", ["xref"], name: "index_invoices_on_xref", unique: true, using: :btree

  create_table "lenders", force: :cascade do |t|
    t.string   "name",                        limit: 255
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "legacy_id",                   limit: 4
    t.integer  "version",                     limit: 4
    t.boolean  "high_volume",                             default: false, null: false
    t.boolean  "can_use_add_cap",                         default: false, null: false
    t.string   "organisation_reference_code", limit: 255
    t.string   "primary_contact_name",        limit: 255
    t.string   "primary_contact_phone",       limit: 255
    t.string   "primary_contact_email",       limit: 255
    t.integer  "std_cap_lending_allocation",  limit: 4
    t.integer  "add_cap_lending_allocation",  limit: 4
    t.boolean  "disabled",                                default: false, null: false
    t.string   "created_by_legacy_id",        limit: 255
    t.string   "modified_by_legacy_id",       limit: 255
    t.boolean  "allow_alert_process",                     default: true,  null: false
    t.string   "main_point_of_contact_user",  limit: 255
    t.string   "loan_scheme",                 limit: 255
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.integer  "created_by_id",               limit: 4,                   null: false
    t.integer  "modified_by_id",              limit: 4,                   null: false
  end

  add_index "lenders", ["legacy_id"], name: "index_lenders_on_legacy_id", unique: true, using: :btree
  add_index "lenders", ["organisation_reference_code"], name: "index_lenders_on_organisation_reference_code", unique: true, using: :btree

  create_table "lending_limits", force: :cascade do |t|
    t.integer  "lender_id",             limit: 4,                   null: false
    t.integer  "legacy_id",             limit: 4
    t.integer  "lender_legacy_id",      limit: 4
    t.integer  "version",               limit: 4
    t.integer  "allocation_type_id",    limit: 4,                   null: false
    t.boolean  "active",                            default: false, null: false
    t.integer  "allocation",            limit: 8,                   null: false
    t.date     "starts_on",                                         null: false
    t.date     "ends_on",                                           null: false
    t.string   "name",                  limit: 255,                 null: false
    t.string   "modified_by_legacy_id", limit: 255
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "modified_by_id",        limit: 4
    t.integer  "phase_id",              limit: 4
  end

  add_index "lending_limits", ["lender_id"], name: "index_lending_limits_on_lender_id", using: :btree
  add_index "lending_limits", ["phase_id"], name: "index_lending_limits_on_phase_id", using: :btree

  create_table "loan_ineligibility_reasons", force: :cascade do |t|
    t.integer  "loan_id",             limit: 4,                 null: false
    t.text     "reason",              limit: 65535
    t.integer  "sequence",            limit: 4,     default: 0, null: false
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "loan_ineligibility_reasons", ["loan_id"], name: "index_loan_ineligibility_reasons_on_loan_id", using: :btree

  create_table "loan_modifications", force: :cascade do |t|
    t.integer  "loan_id",                    limit: 4,               null: false
    t.integer  "created_by_id",              limit: 4,               null: false
    t.string   "oid",                        limit: 255
    t.integer  "seq",                        limit: 4,   default: 0, null: false
    t.date     "date_of_change",                                     null: false
    t.date     "maturity_date"
    t.date     "old_maturity_date"
    t.integer  "lump_sum_repayment",         limit: 8
    t.integer  "amount_drawn",               limit: 8
    t.date     "modified_date",                                      null: false
    t.string   "modified_user",              limit: 255
    t.string   "change_type_id",             limit: 255
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.integer  "amount",                     limit: 8
    t.integer  "old_amount",                 limit: 8
    t.date     "initial_draw_date"
    t.date     "old_initial_draw_date"
    t.integer  "initial_draw_amount",        limit: 8
    t.integer  "old_initial_draw_amount",    limit: 8
    t.integer  "repayment_duration",         limit: 4
    t.integer  "old_repayment_duration",     limit: 4
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "type",                       limit: 255
    t.integer  "repayment_frequency_id",     limit: 4
    t.integer  "old_repayment_frequency_id", limit: 4
  end

  add_index "loan_modifications", ["loan_id", "seq"], name: "index_loan_changes_on_loan_id_and_seq", unique: true, using: :btree

  create_table "loan_realisations", force: :cascade do |t|
    t.integer  "realised_loan_id",         limit: 4,                   null: false
    t.integer  "realisation_statement_id", limit: 4
    t.integer  "created_by_id",            limit: 4,                   null: false
    t.integer  "realised_amount",          limit: 8,                   null: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "legacy_loan_id",           limit: 4
    t.string   "legacy_created_by",        limit: 255
    t.date     "realised_on",                                          null: false
    t.string   "seq",                      limit: 255
    t.string   "ar_timestamp",             limit: 255
    t.string   "ar_insert_timestamp",      limit: 255
    t.boolean  "post_claim_limit",                     default: false, null: false
  end

  add_index "loan_realisations", ["created_by_id"], name: "index_loan_realisations_on_created_by_id", using: :btree
  add_index "loan_realisations", ["realisation_statement_id"], name: "index_loan_realisations_on_realisation_statement_id", using: :btree
  add_index "loan_realisations", ["realised_loan_id"], name: "index_loan_realisations_on_realised_loan_id", using: :btree

  create_table "loan_securities", force: :cascade do |t|
    t.integer  "loan_id",               limit: 4
    t.integer  "loan_security_type_id", limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "loan_securities", ["loan_id"], name: "index_loan_securities_on_loan_id", using: :btree
  add_index "loan_securities", ["loan_security_type_id"], name: "index_loan_securities_on_loan_security_type_id", using: :btree

  create_table "loan_state_changes", force: :cascade do |t|
    t.integer  "loan_id",               limit: 4
    t.string   "legacy_id",             limit: 255
    t.string   "state",                 limit: 255
    t.integer  "version",               limit: 4
    t.integer  "modified_by_id",        limit: 4,   null: false
    t.string   "modified_by_legacy_id", limit: 255
    t.integer  "event_id",              limit: 4,   null: false
    t.datetime "modified_at"
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "loan_state_changes", ["loan_id", "modified_at"], name: "loan_association", using: :btree

  create_table "loans", force: :cascade do |t|
    t.boolean  "viable_proposition",                                                                          null: false
    t.boolean  "would_you_lend",                                                                              null: false
    t.boolean  "collateral_exhausted",                                                                        null: false
    t.integer  "amount",                              limit: 8,                                               null: false
    t.integer  "lender_cap_id",                       limit: 4
    t.integer  "repayment_duration",                  limit: 4,                                               null: false
    t.integer  "turnover",                            limit: 8
    t.date     "trading_date"
    t.string   "sic_code",                            limit: 255,                                             null: false
    t.integer  "loan_category_id",                    limit: 4
    t.integer  "reason_id",                           limit: 4
    t.boolean  "previous_borrowing",                                                                          null: false
    t.boolean  "private_residence_charge_required"
    t.boolean  "personal_guarantee_required"
    t.datetime "created_at",                                                                                  null: false
    t.datetime "updated_at",                                                                                  null: false
    t.integer  "lender_id",                           limit: 4,                                               null: false
    t.boolean  "declaration_signed"
    t.string   "business_name",                       limit: 255
    t.string   "trading_name",                        limit: 255
    t.string   "company_registration",                limit: 255
    t.string   "postcode",                            limit: 255
    t.string   "non_validated_postcode",              limit: 255
    t.string   "sortcode",                            limit: 255
    t.string   "generic1",                            limit: 255
    t.string   "generic2",                            limit: 255
    t.string   "generic3",                            limit: 255
    t.string   "generic4",                            limit: 255
    t.string   "generic5",                            limit: 255
    t.string   "town",                                limit: 255
    t.integer  "interest_rate_type_id",               limit: 4
    t.decimal  "interest_rate",                                     precision: 5,  scale: 2
    t.integer  "fees",                                limit: 8
    t.boolean  "state_aid_is_valid"
    t.boolean  "facility_letter_sent"
    t.date     "facility_letter_date"
    t.boolean  "received_declaration"
    t.boolean  "signed_direct_debit_received"
    t.boolean  "first_pp_received"
    t.date     "maturity_date"
    t.string   "state",                               limit: 255,                                             null: false
    t.integer  "legal_form_id",                       limit: 4
    t.integer  "repayment_frequency_id",              limit: 4
    t.date     "cancelled_on"
    t.integer  "cancelled_reason_id",                 limit: 4
    t.text     "cancelled_comment",                   limit: 65535
    t.date     "borrower_demanded_on"
    t.integer  "amount_demanded",                     limit: 8
    t.date     "repaid_on"
    t.date     "no_claim_on"
    t.date     "dti_demanded_on"
    t.integer  "dti_demand_outstanding",              limit: 8
    t.text     "dti_reason",                          limit: 65535
    t.string   "dti_ded_code",                        limit: 255
    t.integer  "legacy_id",                           limit: 4
    t.string   "reference",                           limit: 255
    t.string   "created_by_legacy_id",                limit: 255
    t.integer  "version",                             limit: 4
    t.date     "guaranteed_on"
    t.string   "modified_by_legacy_id",               limit: 255
    t.integer  "lender_legacy_id",                    limit: 4
    t.integer  "outstanding_amount",                  limit: 8
    t.boolean  "standard_cap"
    t.integer  "next_change_history_seq",             limit: 4
    t.integer  "borrower_demand_outstanding",         limit: 8
    t.date     "realised_money_date"
    t.integer  "event_legacy_id",                     limit: 4
    t.integer  "state_aid",                           limit: 8
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.integer  "notified_aid",                        limit: 4,                               default: 0,     null: false
    t.integer  "remove_guarantee_outstanding_amount", limit: 8
    t.date     "remove_guarantee_on"
    t.string   "remove_guarantee_reason",             limit: 255
    t.integer  "dti_amount_claimed",                  limit: 8
    t.integer  "invoice_legacy_id",                   limit: 4
    t.date     "settled_on"
    t.integer  "next_borrower_demand_seq",            limit: 4
    t.string   "sic_desc",                            limit: 255
    t.string   "sic_parent_desc",                     limit: 255
    t.boolean  "sic_notified_aid"
    t.boolean  "sic_eligible"
    t.string   "non_val_postcode",                    limit: 10
    t.integer  "transferred_from_legacy_id",          limit: 4
    t.integer  "next_in_calc_seq",                    limit: 4
    t.string   "loan_source",                         limit: 1
    t.integer  "dti_break_costs",                     limit: 8
    t.decimal  "guarantee_rate",                                    precision: 16, scale: 2
    t.decimal  "premium_rate",                                      precision: 16, scale: 2
    t.boolean  "legacy_small_loan",                                                           default: false, null: false
    t.integer  "next_in_realise_seq",                 limit: 4
    t.integer  "next_in_recover_seq",                 limit: 4
    t.date     "recovery_on"
    t.integer  "recovery_statement_legacy_id",        limit: 4
    t.integer  "dti_interest",                        limit: 8
    t.string   "loan_scheme",                         limit: 1
    t.decimal  "security_proportion",                               precision: 5,  scale: 2
    t.integer  "current_refinanced_amount",           limit: 8
    t.integer  "final_refinanced_amount",             limit: 8
    t.decimal  "original_overdraft_proportion",                     precision: 5,  scale: 2
    t.decimal  "refinance_security_proportion",                     precision: 5,  scale: 2
    t.integer  "overdraft_limit",                     limit: 8
    t.boolean  "overdraft_maintained"
    t.integer  "invoice_discount_limit",              limit: 8
    t.decimal  "debtor_book_coverage",                              precision: 5,  scale: 2
    t.decimal  "debtor_book_topup",                                 precision: 5,  scale: 2
    t.integer  "lending_limit_id",                    limit: 4
    t.integer  "invoice_id",                          limit: 4
    t.integer  "transferred_from_id",                 limit: 4
    t.integer  "created_by_id",                       limit: 4,                                               null: false
    t.integer  "modified_by_id",                      limit: 4,                                               null: false
    t.string   "legacy_sic_code",                     limit: 255
    t.string   "legacy_sic_desc",                     limit: 255
    t.string   "legacy_sic_parent_desc",              limit: 255
    t.boolean  "legacy_sic_notified_aid",                                                     default: false
    t.boolean  "legacy_sic_eligible",                                                         default: false
    t.integer  "settled_amount",                      limit: 4
    t.string   "lender_reference",                    limit: 255
    t.datetime "last_modified_at"
    t.boolean  "not_insolvent"
    t.decimal  "euro_conversion_rate",                              precision: 17, scale: 14
    t.integer  "loan_sub_category_id",                limit: 4
    t.string   "sub_lender",                          limit: 255
  end

  add_index "loans", ["legacy_id"], name: "index_loans_on_legacy_id", unique: true, using: :btree
  add_index "loans", ["lender_id"], name: "index_loans_on_lender_id", using: :btree
  add_index "loans", ["lending_limit_id"], name: "index_loans_on_lending_limit_id", using: :btree
  add_index "loans", ["reference"], name: "index_loans_on_reference", unique: true, using: :btree
  add_index "loans", ["state"], name: "index_loans_on_state", using: :btree

  create_table "old_passwords", force: :cascade do |t|
    t.string   "encrypted_password",       limit: 255
    t.string   "password_salt",            limit: 255
    t.string   "password_archivable_type", limit: 255, null: false
    t.integer  "password_archivable_id",   limit: 4,   null: false
    t.datetime "created_at"
  end

  add_index "old_passwords", ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable", using: :btree

  create_table "premium_schedules", force: :cascade do |t|
    t.integer  "loan_id",                           limit: 4,                                           null: false
    t.integer  "initial_draw_year",                 limit: 4
    t.integer  "initial_draw_amount",               limit: 8,                                           null: false
    t.integer  "repayment_duration",                limit: 4
    t.integer  "initial_capital_repayment_holiday", limit: 4
    t.integer  "second_draw_amount",                limit: 8
    t.integer  "second_draw_months",                limit: 4
    t.integer  "third_draw_amount",                 limit: 8
    t.integer  "third_draw_months",                 limit: 4
    t.integer  "fourth_draw_amount",                limit: 8
    t.integer  "fourth_draw_months",                limit: 4
    t.datetime "created_at",                                                                            null: false
    t.datetime "updated_at",                                                                            null: false
    t.string   "legacy_loan_id",                    limit: 255
    t.integer  "seq",                               limit: 4
    t.integer  "loan_version",                      limit: 4
    t.string   "calc_type",                         limit: 255
    t.string   "premium_cheque_month",              limit: 255
    t.integer  "holiday",                           limit: 4
    t.integer  "total_cost",                        limit: 4
    t.integer  "public_funding",                    limit: 4
    t.boolean  "obj1_area"
    t.boolean  "reduce_costs"
    t.boolean  "improve_prod"
    t.boolean  "increase_quality"
    t.boolean  "improve_nat_env"
    t.boolean  "promote"
    t.boolean  "agriculture"
    t.integer  "guarantee_rate",                    limit: 4
    t.decimal  "npv",                                           precision: 2, scale: 1
    t.decimal  "prem_rate",                                     precision: 2, scale: 1
    t.integer  "elsewhere_perc",                    limit: 4
    t.integer  "obj1_perc",                         limit: 4
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.boolean  "legacy_premium_calculation",                                            default: false
  end

  add_index "premium_schedules", ["legacy_loan_id"], name: "index_premium_schedules_on_legacy_loan_id", using: :btree
  add_index "premium_schedules", ["loan_id", "seq"], name: "index_premium_schedules_on_loan_id_and_seq", unique: true, using: :btree

  create_table "realisation_statements", force: :cascade do |t|
    t.integer  "lender_id",              limit: 4
    t.integer  "created_by_id",          limit: 4
    t.string   "reference",              limit: 255
    t.string   "period_covered_quarter", limit: 255
    t.string   "period_covered_year",    limit: 255
    t.date     "received_on"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "version",                limit: 255
    t.string   "legacy_id",              limit: 255
    t.string   "legacy_lender_id",       limit: 255
    t.string   "legacy_created_by",      limit: 255
    t.datetime "period_covered_to_date"
    t.string   "ar_timestamp",           limit: 255
    t.string   "ar_insert_timestamp",    limit: 255
  end

  create_table "recoveries", force: :cascade do |t|
    t.integer  "loan_id",                        limit: 4,                   null: false
    t.date     "recovered_on",                                               null: false
    t.integer  "total_proceeds_recovered",       limit: 8,                   null: false
    t.integer  "total_liabilities_after_demand", limit: 8
    t.integer  "total_liabilities_behind",       limit: 8
    t.integer  "additional_break_costs",         limit: 8
    t.integer  "additional_interest_accrued",    limit: 8
    t.integer  "amount_due_to_dti",              limit: 8,                   null: false
    t.boolean  "realise_flag",                               default: false, null: false
    t.integer  "created_by_id",                  limit: 4,                   null: false
    t.integer  "outstanding_non_efg_debt",       limit: 8
    t.integer  "non_linked_security_proceeds",   limit: 8
    t.integer  "linked_security_proceeds",       limit: 8
    t.integer  "realisations_attributable",      limit: 8
    t.integer  "realisations_due_to_gov",        limit: 8
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.integer  "realisation_statement_id",       limit: 4
    t.string   "ar_insert_timestamp",            limit: 255
    t.string   "ar_timestamp",                   limit: 255
    t.string   "legacy_created_by",              limit: 255
    t.string   "legacy_loan_id",                 limit: 255
    t.integer  "seq",                            limit: 4,                   null: false
  end

  add_index "recoveries", ["loan_id"], name: "index_recoveries_on_loan_id", using: :btree

  create_table "sic_codes", force: :cascade do |t|
    t.string  "code",                     limit: 255
    t.string  "description",              limit: 255
    t.boolean "eligible",                             default: false
    t.boolean "public_sector_restricted",             default: false
    t.boolean "active",                               default: true
    t.integer "state_aid_threshold",      limit: 8
  end

  add_index "sic_codes", ["code"], name: "index_sic_codes_on_code", unique: true, using: :btree

  create_table "sub_lenders", force: :cascade do |t|
    t.integer  "lender_id",  limit: 4,   null: false
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sub_lenders", ["lender_id"], name: "index_sub_lenders_on_lender_id", using: :btree

  create_table "user_audits", force: :cascade do |t|
    t.integer  "user_id",               limit: 4
    t.string   "legacy_id",             limit: 255
    t.integer  "version",               limit: 4
    t.integer  "modified_by_id",        limit: 4
    t.string   "modified_by_legacy_id", limit: 255
    t.string   "password",              limit: 255
    t.string   "function",              limit: 255
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "user_audits", ["modified_by_id"], name: "index_user_audits_on_modified_by_id", using: :btree
  add_index "user_audits", ["user_id"], name: "index_user_audits_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255
    t.string   "encrypted_password",     limit: 255
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "lender_id",              limit: 4
    t.integer  "legacy_lender_id",       limit: 4
    t.integer  "version",                limit: 4
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.boolean  "disabled",                           default: false, null: false
    t.string   "memorable_name",         limit: 255
    t.string   "memorable_place",        limit: 255
    t.string   "memorable_year",         limit: 255
    t.integer  "login_failures",         limit: 4
    t.datetime "password_changed_at"
    t.boolean  "locked",                             default: false, null: false
    t.string   "created_by_legacy_id",   limit: 255
    t.integer  "created_by_id",          limit: 4
    t.boolean  "confirm_t_and_c"
    t.string   "modified_by_legacy_id",  limit: 255
    t.integer  "modified_by_id",         limit: 4
    t.boolean  "knowledge_resource"
    t.string   "username",               limit: 255,                 null: false
    t.datetime "ar_timestamp"
    t.datetime "ar_insert_timestamp"
    t.string   "type",                   limit: 255
    t.integer  "failed_attempts",        limit: 4,   default: 0
    t.string   "legacy_email",           limit: 255
    t.string   "password_salt",          limit: 255
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["type"], name: "index_users_on_type", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
