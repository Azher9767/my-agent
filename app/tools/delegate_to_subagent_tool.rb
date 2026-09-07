class DelegateToSubagentTool < RubyLLM::Tool
  description "Delegates a research task to a specialized subagent"

  param :agent, desc: "web_search or document_analysis"
  param :task, desc: "Research task as JSON"

  def execute(agent:, task:)
    task = JSON.parse(task) if task.is_a?(String)

    case agent
    when "web_search"
      Exercise3::WebResearchAgent.new.research(
        topic: task["topic"],
        subtopic: task["subtopic"],
        research_goal: task["research_goal"]
      )

    when "document_analysis"
      Exercise3::DocumentAnalysisAgent.new.analyze(
        topic: task["topic"],
        subtopic: task["subtopic"],
        research_goal: task["research_goal"],
        previous_results: task["previous_results"] || {}
      )

    else
      { error: "Unknown subagent: #{agent}" }
    end
  end
end
