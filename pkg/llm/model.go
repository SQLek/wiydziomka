package llm

type Model struct {
	ID         string `json:"id"`
	Name       string `json:"name"`
	ExternalId string `json:"ident"`
	ProviderId string `json:"provider_id"`
}
