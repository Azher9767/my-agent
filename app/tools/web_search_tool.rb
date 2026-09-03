class WebSearchTool < RubyLLM::Tool
  description "Search the web for information. Returns mock search results."

  param :query, desc: "Search query"

  MOCK_RESULTS = {
    "ruby" => "Ruby was created by Yukihiro Matsumoto.",
    "rails" => "Ruby on Rails is a web application framework written in Ruby.",
    "india" => "India is a country in South Asia."
  }

  def execute(query:)
    result = MOCK_RESULTS.find do |keyword, _|
      query.downcase.include?(keyword)
    end

    result ? result.last : "No mock results found."
  end
end