class AgentTools
  def self.definitions
    [
      {
        name: "calculator",
        description: "Calculate a mathematical expression.",
        input_schema: {
          type: "object",
          properties: {
            expression: {
              type: "string",
              description: "Mathematical expression to calculate."
            }
          },
          required: ["expression"]
        }
      },
      {
        name: "web_search",
        description: "Search the web for information. Returns mock search results.",
        input_schema: {
          type: "object",
          properties: {
            query: {
              type: "string",
              description: "Search query."
            }
          },
          required: ["query"]
        }
      }
    ]
  end

  def self.execute(name, input)
    case name
    when "calculator"
      CalculatorTool.call(input["expression"])
    when "web_search"
      WebSearchTool.call(input["query"])
    else
      { error: "Unknown tool: #{name}" }
    end
  end
end