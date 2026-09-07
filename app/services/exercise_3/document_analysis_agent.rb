module Exercise3
  class DocumentAnalysisAgent
    def initialize
      @chat = RubyLLM.chat(
        provider: :ollama,
        model: "llama3.2:3b",
        assume_model_exists: true
      )
    end

    def analyze(topic:, subtopic:, research_goal:, previous_results:)
      response = @chat.ask(<<~PROMPT)
        You are a document analysis subagent.

        Original research topic:
        #{topic}

        Your assigned subtopic:
        #{subtopic}

        Research goal:
        #{research_goal}

        Previous research results:
        #{previous_results}

        You are an isolated subagent.

        You do not have access to any coordinator or other
        subagent memory unless it is explicitly included above.

        Analyze the provided research context and identify:
        - important findings
        - missing information
        - contradictions
        - areas requiring further research

        Return ONLY valid JSON in this format:

        {
          "findings": [
            {
              "claim": "Solar panel efficiency affects the cost of solar electricity",
              "source_url": null,
              "document_name": "Solar Panel Efficiency Study",
              "page_number": 2,
              "confidence": "high",
              "retrieved_by": "document_analysis_agent"
            }
          ]
        }
      PROMPT

      JSON.parse(response.content)
    end
  end
end
