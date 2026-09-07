module Exercise3
  class WebResearchAgent
    def initialize
      @chat = RubyLLM.chat(
        provider: :ollama,
        model: "llama3.2:3b",
        assume_model_exists: true
      )
    end

    def research(topic:, subtopic:, research_goal:)
      response = @chat.ask(<<~PROMPT)
        You are a web research subagent.

        Original research topic:
        #{topic}

        Your assigned subtopic:
        #{subtopic}

        Research goal:
        #{research_goal}

        You are an isolated subagent.

        You do not have access to the coordinator's memory.
        You only know the context explicitly provided in this prompt.

        Research your assigned subtopic and provide:
        - key technologies
        - current applications
        - advantages
        - limitations
        - future potential
        - source URL
        - source title

        Return ONLY valid JSON in this format:

        {
          "findings": [
            {
              "claim": "Solar panels convert sunlight into electricity",
              "source_url": "https://example.com/solar",
              "document_name": null,
              "page_number": null,
              "confidence": "high",
              "retrieved_by": "web_research_agent"
            }
          ]
        }
      PROMPT

      JSON.parse(response.content)
    end
  end
end
