module Exercise3
  class ResearchSynthesisAgent
    def initialize
      @chat = RubyLLM.chat(
        provider: :ollama,
        model: "llama3.2:3b",
        assume_model_exists: true
      )
    end

    def synthesize(topic:, subtopic:, web_results:, document_results:)
      response = @chat.ask(<<~PROMPT)
        You are a research synthesis subagent.

        Original research topic:
        #{topic}

        Subtopic:
        #{subtopic}

        Web research results:
        #{web_results.to_json}

        Document analysis results:
        #{document_results.to_json}

        Combine the findings into a concise research summary.

        IMPORTANT:
        Preserve all source metadata from the provided findings,
        including:
        - source_url
        - document_name
        - page_number
        - confidence
        - retrieved_by

        Return ONLY valid JSON in this format:

        {
          "findings": [
            {
              "claim": "...",
              "source_url": "...",
              "document_name": "...",
              "page_number": null,
              "confidence": "...",
              "retrieved_by": "..."
            }
          ]
        }
      PROMPT

      JSON.parse(response.content)
    end
  end
end
