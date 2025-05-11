# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Reset the database
puts "Cleaning database..."
# Delete in correct order to respect foreign key constraints
[ Reservation, BookLoan, Book, Member, Author, Category ].each(&:delete_all)

# Create Categories
puts "Creating categories..."
categories = {
  fiction: Category.create!(
    name: "Fiction",
    description: "Fictional literature including novels and short stories"
  ),
  non_fiction: Category.create!(
    name: "Non-Fiction",
    description: "Educational and informative books based on facts"
  ),
  science: Category.create!(
    name: "Science",
    description: "Books about various scientific disciplines"
  ),
  technology: Category.create!(
    name: "Technology",
    description: "Books about computers, programming, and technology"
  )
}

# Create Authors
puts "Creating authors..."
authors = {
  asimov: Author.create!(
    name: "Isaac Asimov",
    biography: "American writer and professor of biochemistry, known for his works of science fiction and popular science"
  ),
  martin: Author.create!(
    name: "Robert C. Martin",
    biography: "American software engineer and author, known for promoting agile software development and software craftsmanship"
  ),
  hawking: Author.create!(
    name: "Stephen Hawking",
    biography: "English theoretical physicist and cosmologist, known for his work on black holes and the origins of the universe"
  )
}

# Create Members
puts "Creating members..."
members = {
  john: Member.create!(
    name: "John Smith",
    email: "john.smith@example.com",
    member_number: "M001",
    status: 0, # active: 0
    phone: "555-0123",
    address: "123 Main St, Anytown, USA"
  ),
  jane: Member.create!(
    name: "Jane Doe",
    email: "jane.doe@example.com",
    member_number: "M002",
    status: 0, # active: 0
    phone: "555-0124",
    address: "456 Oak Ave, Anytown, USA"
  ),
  bob: Member.create!(
    name: "Bob Wilson",
    email: "bob.wilson@example.com",
    member_number: "M003",
    status: 0, # active: 0
    phone: "555-0125",
    address: "789 Pine Rd, Anytown, USA"
  )
}

# Create Books
puts "Creating books..."
books = {
  foundation: Book.create!(
    title: "Foundation",
    isbn: "9780553293357",
    status: 0, # available: 0
    author: authors[:asimov],
    category: categories[:fiction],
    published_date: Date.new(1951, 1, 1),
    description: "The first novel in Asimov's Foundation trilogy"
  ),
  clean_code: Book.create!(
    title: "Clean Code",
    isbn: "9780132350884",
    status: 0, # available: 0
    author: authors[:martin],
    category: categories[:technology],
    published_date: Date.new(2008, 8, 1),
    description: "A handbook of agile software craftsmanship"
  ),
  brief_history: Book.create!(
    title: "A Brief History of Time",
    isbn: "9780553380163",
    status: 0, # available: 0
    author: authors[:hawking],
    category: categories[:science],
    published_date: Date.new(1988, 4, 1),
    description: "A landmark volume in science writing"
  )
}

# Create Book Loans
puts "Creating book loans..."
BookLoan.create!(
  book: books[:foundation],
  member: members[:john],
  borrowed_date: Date.current - 14.days,
  due_date: Date.current + 7.days,
  status: 0  # active: 0
)

BookLoan.create!(
  book: books[:clean_code],
  member: members[:jane],
  borrowed_date: Date.current - 7.days,
  due_date: Date.current + 14.days,
  status: 0  # active: 0
)

# Create Reservations
puts "Creating reservations..."
Reservation.create!(
  book: books[:brief_history],
  member: members[:bob],
  reserved_on: Date.current,
  expiry_date: Date.current + 7.days,
  status: 0  # active: 0
)

puts "Seed data creation completed!"
