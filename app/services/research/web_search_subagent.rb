module Research
  # Subagent isolation: is class ko kisi aur agent ki memory ya context
  # ke baare me kuch nahi pata. Jo bhi chahiye woh `call` ke arguments
  # me EXPLICITLY diya jaata hai — coordinator ki zimmedari hai.
  class WebSearchSubagent
    SYSTEM_PROMPT = <<~SYS
      You are the Web Search Subagent. You have NO memory of any other
      conversation and NO shared context with other agents. You only know
      what is explicitly given to you below. Simulate what a web search on
      this subtopic would surface: 3-4 concrete, factual bullet points.
    SYS

    def self.call(topic:, subtopic:, note: nil)
      user_prompt = <<~PROMPT
        Overall research goal: Produce a comprehensive research report on "#{topic}".
        Your assigned subtopic: "#{subtopic}"
        #{note ? "Targeted follow-up instruction from coordinator: #{note}" : ""}

        Task: Provide 3-4 concise, factual bullet points about "#{subtopic}"
        as it relates to "#{topic}". Be specific, not generic.
      PROMPT

      LlmClient.call(system: SYSTEM_PROMPT, user: user_prompt)
    end
  end
end