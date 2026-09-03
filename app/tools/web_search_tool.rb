class WebSearchTool
  MOCK_RESULTS = {
    "ruby" => "Ruby was created by Yukihiro Matsumoto.",
    "rails" => "Ruby on Rails is a web application framework written in Ruby.",
    "india" => "India is a country in South Asia."
  }

  def self.call(query)
    result = MOCK_RESULTS.find do |keyword, _|
      query.downcase.include?(keyword)
    end

    {
      query: query,
      results: result ? result.last : "No mock results found."
    }
  end
end