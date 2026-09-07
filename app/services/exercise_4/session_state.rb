module Exercise4
  class SessionState
    attr_reader :verified_customer_id

    def mark_customer_verified(customer_id)
      @verified_customer_id = customer_id
    end

    def customer_verified?
      @verified_customer_id.present?
    end
  end
end
