package llm

type Model struct {
	ID         string `json:"id"`
	Name       string `json:"name"`
	ExternalId string `json:"ident"`
	ProviderId string `json:"provider_id"`
}

type OpenRouterModel struct {
	ID            string      `json:"id"`
	Created       int64       `json:"created"`
	Object        interface{} `json:"object"`   // Can be null
	OwnedBy       interface{} `json:"owned_by"` // Can be null
	CanonicalSlug string      `json:"canonical_slug"`
	HuggingFaceID string      `json:"hugging_face_id"`
	Name          string      `json:"name"`
	Description   string      `json:"description"`
	ContextLength int         `json:"context_length"`

	Modality         string   `json:"architecture.modality"`
	InputModalities  []string `json:"architecture.input_modalities"`
	OutputModalities []string `json:"architecture.output_modalities"`
	Tokenizer        string   `json:"architecture.tokenizer"`
	InstructType     string   `json:"architecture.instruct_type"`

	PricingPrompt            string `json:"pricing.prompt"`
	PricingCompletion        string `json:"pricing.completion"`
	PricingRequest           string `json:"pricing.request"`
	PricingImage             string `json:"pricing.image"`
	PricingWebSearch         string `json:"pricing.web_search"`
	PricingInternalReasoning string `json:"pricing.internal_reasoning"`

	TopProviderContextLength       int  `json:"top_provider.context_length"`
	TopProviderMaxCompletionTokens int  `json:"top_provider.max_completion_tokens"`
	TopProviderIsModerated         bool `json:"top_provider.is_moderated"`

	PerRequestLimits    interface{} `json:"per_request_limits"` // Can be null
	SupportedParameters []string    `json:"supported_parameters"`
}

type GroqModel struct {
	ID                  string      `json:"id"`
	Created             int64       `json:"created"`
	Object              string      `json:"object"`
	OwnedBy             string      `json:"owned_by"`
	Active              bool        `json:"active"`
	ContextWindow       int         `json:"context_window"`
	PublicApps          interface{} `json:"public_apps"` // Can be null
	MaxCompletionTokens int         `json:"max_completion_tokens"`
}

type OpenAIModel struct {
	ID      string `json:"id"`
	Object  string `json:"object"`
	Created int64  `json:"created"`
	OwnedBy string `json:"owned_by"`
}

type OllamaModel struct {
	ID      string `json:"id"`
	Object  string `json:"object"`
	Created int64  `json:"created"`
	OwnedBy string `json:"owned_by"`
}

type lmstudioModel struct {
	ID      string `json:"id"`
	Object  string `json:"object"`
	Created int64  `json:"created"`
	OwnedBy string `json:"owned_by"`
}
