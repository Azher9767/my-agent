module Research
  # Hub-and-spoke ka "hub". Yeh khud research nahi karta — sirf:
  #   1) topic ko subtopics me todta hai       (decompose_topic)
  #   2) subagents ko dispatch karta hai        (spawn_subagents_for)
  #   3) results collect + evaluate karta hai   (evaluate_coverage)
  #   4) gaps mile to re-delegate karta hai     (iterative_refinement_loop)
  #   5) final report banata hai                (build_final_report)
  class Coordinator
    MAX_ITERATIONS = 3

    SYSTEM_PROMPT = <<~SYS
      You are the Research Coordinator in a hub-and-spoke multi-agent system.
      You own task decomposition, subagent dispatch, and result aggregation.
      You never do the research yourself — you only plan, delegate, and evaluate.
      You always aim for BROAD coverage of a topic, not just the two or three
      most obvious subtopics. Narrow decomposition is a failure.
    SYS

    def initialize(topic)
      @topic = topic
      @subtopics = []
      # subtopic => { web: "...", doc: "..." }
      @findings = {}
    end

    def run
      decompose_topic
      spawn_subagents_for(@subtopics)
      iterative_refinement_loop
      build_final_report
    end

    private

    # -- Step 2: decomposition, at least 5 distinct subtopics -----------
    def decompose_topic
      prompt = <<~PROMPT
        Topic: "#{@topic}"

        Break this broad topic into at least 5 (ideally 6-8) DISTINCT subtopics
        that together cover its FULL breadth — not just the most famous or
        obvious ones. Think about: major categories, less-common or emerging
        variants, supporting/complementary areas, and cutting-edge research
        directions. Avoid narrow decomposition.

        Output ONLY a comma-separated list of short subtopic names. No numbering,
        no extra text, no explanation.
      PROMPT

      @subtopics = parse_subtopics(LlmClient.call(system: SYSTEM_PROMPT, user: prompt))

      return unless @subtopics.size < 5

      # Chhote local models kabhi kabhi shortcut lete hain — ek retry.
      stronger_prompt = prompt + "\n\nYour previous attempt gave too few subtopics. " \
                                  "You MUST list at least 6."
      @subtopics = parse_subtopics(LlmClient.call(system: SYSTEM_PROMPT, user: stronger_prompt))
    end

    def parse_subtopics(raw)
      raw.split(",").map { |s| s.strip.downcase }.reject(&:empty?).uniq
    end

    # -- Step 3: spawn subagents, explicit context every time -----------
    def spawn_subagents_for(subtopics, note: nil)
      subtopics.each do |subtopic|
        @findings[subtopic] ||= {}
        @findings[subtopic][:web] = WebSearchSubagent.call(topic: @topic, subtopic: subtopic, note: note)
        @findings[subtopic][:doc] = DocumentAnalysisSubagent.call(topic: @topic, subtopic: subtopic, note: note)
      end
    end

    # -- Step 4: aggregate + evaluate coverage ---------------------------
    def evaluate_coverage
      preview = @subtopics.map do |st|
        f = @findings[st] || {}
        "- #{st}: web=[#{f[:web].to_s[0, 120]}...] doc=[#{f[:doc].to_s[0, 120]}...]"
      end.join("\n")

      prompt = <<~PROMPT
        Original broad topic: "#{@topic}"
        Subtopics assigned: #{@subtopics.join(', ')}

        Findings so far (truncated preview per subtopic):
        #{preview}

        For EACH subtopic, classify coverage as exactly one of:
        covered, partial, missing

        Output ONLY in this exact format, one line per subtopic, nothing else:
        subtopic_name: status
      PROMPT

      raw = LlmClient.call(system: SYSTEM_PROMPT, user: prompt)
      parse_coverage(raw)
    end

    def parse_coverage(raw)
      coverage = {}
      raw.each_line do |line|
        next unless line =~ /^\s*([\w\s\-]+?)\s*:\s*(covered|partial|missing)\s*$/i

        coverage[$1.strip.downcase] = $2.strip.downcase.to_sym
      end

      # Fallback agar model format todta hai — hard fail nahi karna.
      @subtopics.each do |st|
        next if coverage[st]

        f = @findings[st] || {}
        total_len = f[:web].to_s.length + f[:doc].to_s.length
        coverage[st] = total_len > 150 ? :covered : (total_len > 40 ? :partial : :missing)
      end

      coverage
    end

    # -- Step 5: iterative refinement loop -------------------------------
    def iterative_refinement_loop
      MAX_ITERATIONS.times do
        coverage = evaluate_coverage
        gaps = coverage.select { |_, status| status != :covered }.keys
        return if gaps.empty?

        note = "Previous attempt on this subtopic was insufficient. " \
               "Go deeper and be more specific and concrete."
        spawn_subagents_for(gaps, note: note)
      end
    end

    # -- Final report ------------------------------------------------------
    def build_final_report
      coverage = evaluate_coverage
      covered_count = coverage.values.count { |s| s == :covered }
      pct = ((covered_count.to_f / @subtopics.size) * 100).round

      report = +"=== FINAL RESEARCH REPORT: #{@topic} ===\n"
      report << "Coverage: #{covered_count}/#{@subtopics.size} subtopics fully covered (#{pct}%)\n\n"

      @subtopics.each do |st|
        f = @findings[st] || {}
        report << "## #{st.capitalize} [#{coverage[st]}]\n"
        report << "Web findings:\n#{f[:web]}\n\n"
        report << "Analysis:\n#{f[:doc]}\n\n"
      end

      { report: report, coverage: coverage, subtopics: @subtopics }
    end
  end
end