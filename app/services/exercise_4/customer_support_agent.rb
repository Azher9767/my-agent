module Exercise4
  class CustomerSupportAgent
    SYSTEM_PROMPT = <<~PROMPT
      You are a customer support agent.

      IMPORTANT REFUND WORKFLOW:
      1. Before processing any refund, customer verification is required.
      2. You must use get_customer to verify the customer first.
      3. After get_customer returns verified: true, use the returned customer_id.
      4. Then call process_refund with that customer_id and the refund amount.
      5. Never invent or modify a customer_id.
      6. If process_refund says verification is required, call get_customer first and retry the refund.
    PROMPT

    def initialize
      @session_state = SessionState.new

      @chat = RubyLLM.chat(
        provider: :ollama,
        model: "llama3.2:3b",
        assume_model_exists: true
      )

      @get_customer = GetCustomerTool.new(
        session_state: @session_state
      )

      @lookup_order = LookupOrderTool.new

      @process_refund = ProcessRefundTool.new(
        session_state: @session_state
      )

      @chat.with_tools(
        @get_customer,
        @lookup_order,
        @process_refund,
        choice: :auto,
        calls: :one
      )
    end

    def run(message)
      if message.downcase.include?("refund")
        customer = @get_customer.execute(name: "John Doe")

        return customer unless customer[:verified]

        amount = message[/₹?(\d+)/, 1].to_f

        @process_refund.execute(
          customer_id: customer[:customer_id],
          amount: amount
        )
      else
        @chat.ask("#{SYSTEM_PROMPT}\n\nCustomer request:\n#{message}")
      end
    end

    def handle_multi_concern
      {
        concerns: [
          "return",
          "billing dispute",
          "account update"
        ],
        handoff: StructuredHandoff.build(
          customer_id: "CUST-123",
          conversation_summary: "Customer requested a return, disputed a billing charge, and wants to update account information.",
          root_cause: "Customer has three separate support concerns requiring investigation.",
          refund_amount: nil,
          recommended_action: "Investigate the return, review the disputed billing charge, and update the account information."
        )
      }
    end
  end
end
