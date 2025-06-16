[![License](https://img.shields.io/github/license/SQLek/wiydziomka)](./LICENSE)
# Wiydziomka

A small-scale LLM chatting service.  
Something to bridge the gap between _“I'm doing everything manually and locally”_  
and _“IaaS – intelligence as a service”_.

No need for a PhD or engineering degree in Kubernetes and serverless cloud.

It is an entry for the [T3.chat cloneathon](https://cloneathon.t3.chat/)

None of this would be possible without **[PocketBase](https://pocketbase.io/)** –  
it's like Firebase, but in a single executable.  
Extend it with JS, TS, or Go – and still ship it all in one binary.

## Installation

 - ~~Download executable from releases and double click~~... soon™
 - ~~Docker pull~~... soon™
 - ~~Flatpack/Snap/winget~~... soon™
 - ~~Wiydziomka Cloud~~... Nowhere near ready — billing, payments, security, and privacy are still missing. We prefer to stay small-scale for now.
 - **From sources**

Make sure you have [Golang](https://go.dev/dl/)
and [Flutter](https://docs.flutter.dev/get-started/install) installed.

```shell
git clone https://github.com/SQLek/wiydziomka.git
flutter build web
go build ./cmd/wiydziomka
```

Commands above will clone this repo and compile executable.

## Usage & maintanance

First start will generate OTP link to set up a superuser.
```shell
wiydziomka serve
```
You can always add another superuser from console.

```shell
wiydziomka superuser upsert EMAIL PASS
```

#### A word of caution:
Data store, named `pb_store` is generated
in ***same location as executable***, no mater of working directory.

You can use `--dev` to have verbose output and `--dir <location>`
to change store placement.

## Adding users, models, providers:
Enter pocketbase panel
```
http://127.0.0.1:8090/_/
```

#### adding user:
- Go to the `users` and click **+New record**
- enter `email` used as login, `password` (and confirm it)
- enable `verifed`
- enter name and optionally add your avatar
- Click **Create**

#### enabling provider:
- go to `providers` and edit existing one
- enable `isActive` 
- add your `apiKey` 
- **Save changes**

#### adding new provider:
- Make sure your provider supports OpenAI-style JSON requests (`/chat/completions` is appended automatically)
- go to providers and click **+New record**
- enter provider `name`
- enter `baseUrl `
- enter your `apiKey`
- enable `isActive`
- if your provider is an local LLM enable `isLocal`
- **Create**

#### adding new models:
- go to `models` and click **+New record**
- Select a `provider` using the **Open picker** button
- enter `name` of your model
- enter `ident` (this is the provider’s API model name – check their docs)
- Optionally enable:
   - `isPreferred` (sets this model as default)
   - `isThinking` (marks it as a “thinking” model)
- **Create**

## Room full of 🐘

Every project – especially one built on a tight schedule – births a few elephants (and other quirks).
You might get a few eurekas, but let’s deal with the zoology first.

### Where’s the Apple Support?

Oh, how naive we were.
"Just add some flags in GitHub Actions" or `flutter build ios`, right?

> You guys can just tap the executable on your phone or macbook and run it, right?

Supporting Apple without owning Apple products (or knowing someone who does) was one of the reasons we chose Flutter in the first place...
At the very least, you should be able to compile it from source on your MacBook 🙃


### Flutter – Your Dart to the Knee

Our team is mainly backend.  
With plenty of "vibe coding" experience, we knew LLMs love to paint themselves into architectural corners — especially when there’s no solid refactoring strategy.

In Go, it’s not a big problem. No harm in deprecated `ioutil` or a naked `done <-chan struct{}`.  
We can usually guide the model away from the worst footguns.  
The more deprecated or irrelevant baggage, the more likely it is to hallucinate itself into a corner with nonexistent libraries and functions.

Even in Flutter, we managed to corner ourselves — this time into an inability to add routing.  
But it was manageable to escape without a full rewrite.

Moving forward, we’re considering Svelte, Vue, or even React Native —  
if we can figure out how to make a Linux desktop build from it. 🙂

### No streaming response?

Groq is fast enough that even reasoning models feel almost instantaneous.  
For Ollama, the RX 6900 XT we have in our system is snappy enough not to complain.  
Probably someone could use LM Studio and get away with a GPU as low as a GTX 1080 Ti,  
or even an Intel A770 16G — without major issues.

### Everything Through the Backend?

Provisioning API keys to the frontend is an interesting idea —  
definitely worth investigating further.  
Maybe something like [Goja](https://github.com/dop251/goja) could help share logic  
between the backend and frontend?

Or maybe WebGPU — and run inference directly on the edge...

### Lots of Elephants — But Where's the Original One?

Why not PHP? Laravel + Inertia was on the table.  
I've heard the developer experience is actually very good nowadays.

And the same could be said for many other techs:  
**Why not...** Zig? htmx? Rust? Alpine.js? Templ?

So many promising and interesting options.  
But no time to evaluate — and not willing to risk **not shipping**.

### Eurekas from This Project

❤️ **[PocketBase](https://pocketbase.io/)** ❤️  
Building an SPA with it was a breeze — everything handled with minimal complexity.  
Probably not the best option for SSR, though.

#### Vibe Critique
Maybe LLMs can’t come up with great architecture, 
but they’re excellent at critiquing _your_ code.

Still, the ability to discuss whether I should use a provider, model, or just _state_ was a godsend.

#### You don't need bels and whistles! 
'm already using this project for tasks I’d normally run through Gemini Pro.  
There’s a model on **Groq** with web search integration,  
called `compound-beta`, and it looks promising.

Don’t compete on features others already got right —  
you’ll have a hard time catching up.  
Compete on features **you** actually need —  
especially the ones that are nonexistent elsewhere.

## Future Plans:

### Studio Mode

Groq has a nice feature in its developer console:  
Studio Mode, which allows easy experimenting with system prompts,  
context messages, and A/B testing of different models.

o persistence and manual copy-pasting required.  
Adding persistence in Wiydziomka will enable us  
to deliver a much better Studio Mode experience.

### Exposing Tools to Users

There is currently no user interface exposing MSPs or tools.  
This isn’t a feature that benefits the average end user,  
but power users, content creators, and domain experts  
would benefit greatly from it.

### Embeddings and RAGs

In a perfect world, an AI system would learn and grow by interacting with its own user.  
Actually, long-term memory and user context are hidden at best, and nonexistent in most cases.

As a stopgap, we can expose the embedding database and RAGs to the user.  
The closest thing that exists is a coding agent that asks for permission before performing an action in the terminal.

We humans are bad at describing ourselves.  
User allergic to peanuts? Dislikes `2 + 2 - 2 = 20` language? Don’t have a car?  
It’s possible to iteratively get the system prompt good enough,  
but it’s hard and very manual.

We probably can use the LLM itself to close the loop,  
but it has to be supervised —  
preferably by the user, without introducing too much friction.

## Last words

We aimed for a **minimal plan** — just to finish. Even coming in last place is a success.  
In the unlikely event of winning any prize, we prefer to donate it to charity,  
chosen by Theo.

We would like the charity to be involved in one of the following areas:

- Spreading knowledge  
- Digital inclusion  
- Repairability  

Thank you for spending time with us.  
We would love to hear more from you.  
Maybe use the issues tab?
