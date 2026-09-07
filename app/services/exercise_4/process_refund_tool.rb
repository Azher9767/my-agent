module Exercise4
  class ProcessRefundTool < RubyLLM::Tool
    description "Process a refund"

    param :customer_id, type: "string", desc: "Verified customer ID"
    param :amount, type: "number", desc: "Refund amount"

    def initialize(session_state:)
      @session_state = session_state
    end

    def execute(customer_id:, amount:)
      unless @session_state.customer_verified?
        return {
          success: false,
          error: "Cannot process refund — customer identity not verified."
        }
      end

      {
        success: true,
        customer_id: customer_id,
        refunded_amount: amount
      }
    end
  end
end
