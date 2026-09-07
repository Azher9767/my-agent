module Exercise4
  class LookupOrderTool < RubyLLM::Tool
    description "Look up an order"

    param :order_id, type: "string", desc: "Order ID"

    def execute(order_id:)
      {
        order_id: order_id,
        amount: 1000,
        status: "delivered"
      }
    end
  end
end
