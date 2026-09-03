class CalculatorTool < RubyLLM::Tool
  description "Calculate a mathematical expression."

  param :expression, desc: "Mathematical expression to calculate"

  def execute(expression:)
    eval(expression).to_s
  rescue StandardError => e
    "Error: #{e.message}"
  end
end