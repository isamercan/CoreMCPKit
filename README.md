# CoreMCPKit

**CoreMCPKit** is a modular, plugin-based Swift framework built to support the **Model Context Protocol (MCP)**. It enables developers to create context-aware AI agents that integrate seamlessly with various Large Language Models (LLMs) and dynamic data sources.

---

## 🚀 Features

- 🧠 **LLM-Agnostic**: Compatible with OpenAI, Claude, Mistral, and more.
- 🧩 **Plugin Architecture**: Contexts are managed by independent providers.
- 💬 **Emotion-Aware Responses**: Detects user emotions and adapts tone dynamically.
- 🔄 **Multi-Context Support**: Combines multiple contexts for richer LLM interactions.
- 🔧 **Easy Configuration**: Integrate your own API keys with minimal setup.

---

## 📦 Installation

### Swift Package Manager
Add **CoreMCPKit** to your project using Swift Package Manager by including it in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/isamercan/CoreMCPKit.git", .upToNextMajor(from: "1.0.0"))
]
```

Then, import the library in your code:

```swift
import CoreMCPKit
```

---

## ⚙️ Configuration

Configure **CoreMCPKit** by setting up the `MCPAgentManager` and registering context providers:

```swift
import CoreMCPKit

// Initialize configuration with your OpenAI API key
let config = MCPConfiguration(openAIApiKey: "sk-...")

// Create the MCP agent manager
let manager = MCPAgentManager(config: config)

// Register context providers
let openAI = OpenAIProvider(apiKey: config.openAIApiKey)
let parser = PromptToFlexibleQueryParser(openAIService: openAI)

manager.registerProvider(FlexibleContextProvider(parser: parser))
manager.registerProvider(EmotionContextProvider(openAIService: openAI))
```

---

## 📝 Example Usage

Process user input and generate context-aware responses with the following code:

```swift
Task {
    do {
        let userInput = "I'm looking for affordable villas in Antalya for June, prices are too high!"
        let response = try await manager.respond(to: userInput)
        print(response)
    } catch {
        print("Error: \(error)")
    }
}
```

---

## 📚 Additional Information

- **Documentation**: Visit the [GitHub Wiki](https://github.com/username/CoreMCPKit/wiki) for detailed guides.
- **Support**: Reach out with questions via [GitHub Issues](https://github.com/username/CoreMCPKit/issues).
- **License**: CoreMCPKit is distributed under the MIT License.
