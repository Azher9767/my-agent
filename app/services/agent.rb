class Agent
  def initialize(model: "llama3.2:3b")
    RubyLLM.chat(
      provider: :ollama,
      model: "llama3.2:3b",
      assume_model_exists: true
    ).ask("Search for who created Ruby, then calculate 10 + 5.").content

    @chat.with_tools(
      CalculatorTool,
      WebSearchTool
    )
  end

  def run(prompt)
    @chat.ask(prompt).content
  end
end
