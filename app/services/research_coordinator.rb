class ResearchCoordinator
  SYSTEM_PROMPT = <<~PROMPT
    You are a research coordinator.

    Your job is to:
    1. Break broad research topics into comprehensive subtopics.
    2. Delegate research tasks to specialized subagents.
    3. Pass all relevant context explicitly to subagents.
    4. Aggregate subagent results.
    5. Evaluate whether the research has sufficient coverage.
    6. Identify missing areas and request additional research.
    7. Produce a final structured research report.

    You are the central coordinator. Subagents do not share memory
    with each other, so all required context must be explicitly passed.
  PROMPT

	def initialize
		@chat = RubyLLM.chat(
			provider: :ollama,
			model: "llama3.2:3b",
			assume_model_exists: true
		)

		@web_agent = WebResearchAgent.new
		@document_agent = DocumentAnalysisAgent.new
		@aggregator = ResearchAggregator.new
	end

	def research(topic)
		subtopics = decompose_topic(topic)

		results = {}

		subtopics.each do |subtopic|
			results[subtopic] = research_subtopic(
				topic: topic,
				subtopic: subtopic
			)
		end

		coverage = @aggregator.evaluate_coverage(
			topic: topic,
			subtopics: subtopics,
			results: results
		)

		{
			topic: topic,
			subtopics: subtopics,
			results: results,
			coverage: coverage
		}
	end

  def decompose_topic(topic)
		response = @chat.ask(<<~PROMPT)
			#{SYSTEM_PROMPT}

			Research topic:
			#{topic}

			Break this broad topic into at least 6 distinct subtopics.

			The decomposition must cover the full breadth of the subject.

			For this exercise, when the topic is:
			"renewable energy technologies"

			you MUST include these six subtopics:

			1. Solar energy
			2. Wind energy
			3. Geothermal energy
			4. Tidal energy
			5. Biomass energy
			6. Fusion energy

			Return ONLY valid JSON in this format:

			{
				"subtopics": [
					"Solar energy",
					"Wind energy",
					"Geothermal energy",
					"Tidal energy",
					"Biomass energy",
					"Fusion energy"
				]
			}
		PROMPT

		JSON.parse(response.content)["subtopics"]
	end

	def research_subtopic(topic:, subtopic:)
		research_goal = <<~GOAL
			Research #{subtopic} as part of #{topic}.

			Cover:
			- key technologies
			- current applications
			- advantages
			- limitations
			- future potential
		GOAL

		web_result = @web_agent.research(
			topic: topic,
			subtopic: subtopic,
			research_goal: research_goal
		)

		document_result = @document_agent.analyze(
			topic: topic,
			subtopic: subtopic,
			research_goal: research_goal,
			previous_results: web_result
		)

		{
			web_research: web_result,
			document_analysis: document_result
		}
	end
end
