class CalculatorTool
  def self.call(expression)
    result = eval(expression)

    {
      expression: expression,
      result: result
    }
  rescue StandardError => e
    {
      expression: expression,
      error: e.message
    }
  end
end