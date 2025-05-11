class CreateBookLoans < ActiveRecord::Migration[7.1]
  def change
    create_table :book_loans do |t|
      t.references :book, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true
      t.date :borrowed_date, null: false
      t.date :due_date, null: false
      t.date :returned_date
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :book_loans, :status
    add_index :book_loans, :due_date
    add_index :book_loans, :borrowed_date
  end
end
