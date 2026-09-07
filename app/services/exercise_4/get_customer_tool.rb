module Exercise4
  class GetCustomerTool < RubyLLM::Tool
    description "Find and verify a customer"

    param :name, type: "string", desc: "Customer name", required: false
    param :email, type: "string", desc: "Customer email", required: false

    def initialize(session_state:)
      @session_state = session_state
    end

    def execute(name: nil, email: nil)
      result = {
        customer_id: "CUST-123",
        verified: true
      }

      @session_state.mark_customer_verified(result[:customer_id]) if result[:verified]

      result
    end
  end
end
