module Research
  # Ek hi jagah se LLM call hota hai — coordinator aur dono subagents
  # isi ko use karte hain (DRY). Yahan koi tool-calling nahi hai kyunki
  # subagents khud simulated LLM personas hain, real tools nahi.
  class LlmClient
    MODEL = "llama3.2:3b"

    def self.call(system:, user:)
      RubyLLM.chat(
        provider: :ollama,
        model: MODEL,
        assume_model_exists: true
      ).with_instructions(system)
       .ask(user)
       .content
    end
  end
end