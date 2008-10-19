class Deposit < Transaction
  belongs_to :account

  after_destroy :delete_transaction_pair

  protected
  def delete_transaction_pair
    if transfer_transaction_id
      from = Transaction.find(transfer_transaction_id)
      from.destroy
    end
  end
end