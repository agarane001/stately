# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_11_041216) do
  create_table "authors", force: :cascade do |t|
    t.string "name"
    t.text "biography"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "book_loans", force: :cascade do |t|
    t.integer "book_id", null: false
    t.integer "member_id", null: false
    t.date "borrowed_date", null: false
    t.date "due_date", null: false
    t.date "returned_date"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_book_loans_on_book_id"
    t.index ["borrowed_date"], name: "index_book_loans_on_borrowed_date"
    t.index ["due_date"], name: "index_book_loans_on_due_date"
    t.index ["member_id"], name: "index_book_loans_on_member_id"
    t.index ["status"], name: "index_book_loans_on_status"
  end

  create_table "books", force: :cascade do |t|
    t.string "title", null: false
    t.string "isbn", null: false
    t.integer "status", default: 0, null: false
    t.integer "author_id", null: false
    t.integer "category_id", null: false
    t.date "published_date"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_books_on_author_id"
    t.index ["category_id"], name: "index_books_on_category_id"
    t.index ["isbn"], name: "index_books_on_isbn", unique: true
    t.index ["status"], name: "index_books_on_status"
    t.index ["title"], name: "index_books_on_title"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "members", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "member_number", null: false
    t.integer "status", default: 0, null: false
    t.string "phone"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_members_on_email", unique: true
    t.index ["member_number"], name: "index_members_on_member_number", unique: true
    t.index ["status"], name: "index_members_on_status"
  end

  create_table "reservations", force: :cascade do |t|
    t.integer "book_id", null: false
    t.integer "member_id", null: false
    t.date "reserved_on", null: false
    t.date "expiry_date", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_reservations_on_book_id"
    t.index ["expiry_date"], name: "index_reservations_on_expiry_date"
    t.index ["member_id"], name: "index_reservations_on_member_id"
    t.index ["reserved_on"], name: "index_reservations_on_reserved_on"
    t.index ["status"], name: "index_reservations_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "member", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "book_loans", "books"
  add_foreign_key "book_loans", "members"
  add_foreign_key "books", "authors"
  add_foreign_key "books", "categories"
  add_foreign_key "reservations", "books"
  add_foreign_key "reservations", "members"
end
