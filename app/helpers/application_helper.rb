module ApplicationHelper
  def status_badge(status, type = nil)
    base_classes = "px-2 inline-flex text-xs leading-5 font-semibold rounded-full"

    color_classes = case type
    when "book"
      case status.to_sym
      when :available then "bg-green-100 text-green-800"
      when :borrowed then "bg-yellow-100 text-yellow-800"
      when :reserved then "bg-blue-100 text-blue-800"
      when :maintenance then "bg-gray-100 text-gray-800"
      end
    when "member"
      case status.to_sym
      when :active then "bg-green-100 text-green-800"
      when :suspended then "bg-red-100 text-red-800"
      when :expired then "bg-gray-100 text-gray-800"
      end
    when "reservation"
      case status.to_sym
      when :active then "bg-blue-100 text-blue-800"
      when :fulfilled then "bg-green-100 text-green-800"
      when :cancelled then "bg-gray-100 text-gray-800"
      when :expired then "bg-red-100 text-red-800"
      end
    else
      "bg-gray-100 text-gray-800"
    end

    "#{base_classes} #{color_classes}"
  end

  def format_date(date)
    return unless date
    date.strftime("%B %d, %Y")
  end

  def format_datetime(datetime)
    return unless datetime
    datetime.strftime("%B %d, %Y at %I:%M %p")
  end

  def back_button(path)
    link_to path, class: "inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500" do
      raw('<svg class="-ml-1 mr-2 h-5 w-5 text-gray-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z" clip-rule="evenodd" />
      </svg>Back')
    end
  end

  def form_button(text)
    button_tag text,
      type: "submit",
      class: "inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
  end

  def days_overdue(due_date)
    return 0 unless due_date && due_date < Date.current
    (Date.current - due_date).to_i
  end

  def format_short_date(date)
    return unless date
    date.strftime("%b %d, %Y")
  end

  def loan_status_classes(loan)
    base_classes = "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"

    status_classes = if loan.returned?
      "bg-gray-100 text-gray-800"
    elsif loan.overdue?
      "bg-red-100 text-red-800"
    else
      "bg-green-100 text-green-800"
    end

    "#{base_classes} #{status_classes}"
  end

  def can_return_book?(loan)
    loan.active? && !loan.returned?
  end

  def can_extend_loan?(loan)
    loan.active? && !loan.overdue?
  end

  def admin?
    current_user&.admin?
  end

  def librarian?
    current_user&.librarian?
  end

  def staff?
    admin? || librarian?
  end

  def member?
    current_user&.member?
  end

  def can?(action, record)
    policy(record).public_send("#{action}?")
  end

  def new_book_link
    if can?(:create, Book)
      link_to "New Book", new_book_path
    end
  end
end
