class Agent
  MAX_ITERATIONS = 20

  def initialize(model: "llama3.2:3b")
    @chat = RubyLLM.chat(
      provider: :ollama,
      model: model,
      assume_model_exists: true
    )
  end

  def run(prompt)
    messages = [
      {
        role: "user",
        content: prompt
      }
    ]

    iteration = 0

    loop do
      iteration += 1

      if iteration > MAX_ITERATIONS
        warn "WARNING: Agent reached maximum iteration limit."
        return "Agent stopped because the maximum iteration limit was reached."
      end

      response = @chat.ask(messages)

      tool_calls = extract_tool_calls(response)

      if tool_calls.any?
        puts "Tool call requested: #{tool_calls.inspect}"

        messages << {
          role: "assistant",
          content: response.content
        }

        tool_calls.each do |tool_call|
          result = AgentTools.execute(
            tool_call[:name],
            tool_call[:input]
          )

          messages << {
            role: "user",
            content: [
              {
                type: "tool_result",
                tool_use_id: tool_call[:id],
                content: result.to_json
              }
            ]
          }
        end

        next
      end

      return response.content
    end
  end

  private

  def extract_tool_calls(response)
    []
  end
end