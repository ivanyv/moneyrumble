module TransactionsHelper
  def number_to_currency0(number, options = {})
    return if number == 0
    number_to_currency number, options
  end
end
