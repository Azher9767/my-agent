class ResearchAggregator
  def initialize
    @chat = RubyLLM.chat(
      provider: :ollama,
      model: "llama3.2:3b",
      assume_model_exists: true
    )
  end

  def evaluate_coverage(topic:, subtopics:, results:)
    response = @chat.ask(<<~PROMPT)
      You are the research coordinator evaluating research coverage.

      Original research topic:
      #{topic}

      Required subtopics:
      #{subtopics.join("\n")}

      Research results:
      #{results.to_json}

      Evaluate how completely the required subtopics are covered.

      For every required subtopic, classify it as:
      - well-covered
      - partially-covered
      - missing

      Identify any missing or partially-covered subtopics.

      Return ONLY valid JSON in this format:

      {
        "coverage": {
          "subtopic name": "well-covered"
        },
        "gaps": [
          "missing subtopic"
        ],
        "coverage_percentage": 0
      }
    PROMPT

    JSON.parse(response.content)
  end
end