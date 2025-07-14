package llm

type Model struct {
	ID         string `json:"id"`
	Name       string `json:"name"`
	ExternalId string `json:"ident"`
	ProviderId string `json:"provider_id"`
}

type OpenRouterModel struct {
	ID            string `json:"id"`
	Created       int64  `json:"created"`
	Object        any    `json:"object"`   // Can be null
	OwnedBy       any    `json:"owned_by"` // Can be null
	CanonicalSlug string `json:"canonical_slug"`
	HuggingFaceID string `json:"hugging_face_id"`
	Name          string `json:"name"`
	Description   string `json:"description"`
	ContextLength int    `json:"context_length"`

	Architecture        OpenRouterArchitecture `json:"architecture"`
	Pricing             OpenRouterPricing      `json:"pricing"`
	TopProvider         OpenRouterTopProvider  `json:"top_provider"`
	PerRequestLimits    any                    `json:"per_request_limits"`
	SupportedParameters []string               `json:"supported_parameters"`
}

type OpenRouterArchitecture struct {
	Modality         string   `json:"modality"`
	InputModalities  []string `json:"input_modalities"`
	OutputModalities []string `json:"output_modalities"`
	Tokenizer        string   `json:"tokenizer"`
	InstructType     *string  `json:"instruct_type"`
}

type OpenRouterPricing struct {
	Prompt            string `json:"prompt"`
	Completion        string `json:"completion"`
	Request           string `json:"request"`
	Image             string `json:"image"`
	WebSearch         string `json:"web_search"`
	InternalReasoning string `json:"internal_reasoning"`
}

type OpenRouterTopProvider struct {
	ContextLength       int  `json:"context_length"`
	MaxCompletionTokens int  `json:"max_completion_tokens"`
	IsModerated         bool `json:"is_moderated"`
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
