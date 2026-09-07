module Exercise4
  class StructuredHandoff
    REQUIRED_FIELDS = %i[
      customer_id
      conversation_summary
      root_cause
      refund_amount
      recommended_action
    ].freeze

    def self.build(
      customer_id:,
      conversation_summary:,
      root_cause:,
      refund_amount: nil,
      recommended_action:
    )
      {
        customer_id: customer_id,
        conversation_summary: conversation_summary,
        root_cause: root_cause,
        refund_amount: refund_amount,
        recommended_action: recommended_action
      }
    end
  end
end
