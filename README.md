[![License](https://img.shields.io/github/license/SQLek/wiydziomka)](./LICENSE)
# Wiydziomka

A small-scale LLM chatting service.  
Something to bridge the gap between _“I'm doing everything manually and locally”_  
and _“IaaS – intelligence as a service”_.

No need for a PhD or an engineering degree in Kubernetes and a serverless cloud.

It is an entry for the [T3.chat cloneathon](https://cloneathon.t3.chat/)

None of this would be possible without **[PocketBase](https://pocketbase.io/)** –  
it's like Firebase, but in a single executable.  
Extend it with JS, TS, or Go – and still ship it all in one binary.

## Installation

 - ~~Download the executable from releases and double click~~... soon™
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

Commands above will clone this repo and compile the executable.

## Usage & maintanance

First start will generate OTP link to set up a superuser.
```shell
wiydziomka serve
```
You can always add another superuser from the console.

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
- Go to `users` and click **+New record**
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

> You guys can just tap the executable on your phone or MacBook and run it, right?

Supporting Apple without owning Apple products (or knowing someone who does) was one of the reasons we chose Flutter in the first place...
At the very least, you should be able to compile it from source on your MacBook 🙃

### Flutter – Your Dart to the Knee

Our team is primarily backend, without much frontend intuition.  
We were worried that no amount of vibe coding would help us navigate the modern JavaScript landscape — with all its glory and years of accumulated baggage.

We believed Flutter's constrained ecosystem would be easier for us and the LLM to navigate.  
In hindsight, our worries were overstated — but Flutter itself wasn't very pleasant for building web applications.

Moving forward, we’re considering Svelte or Vue.

### No streaming response?

Groq is fast enough that even reasoning models feel almost instantaneous.  
For Ollama, the RX 6900 XT we have in our system is snappy enough not to complain.  
Probably someone could use LM Studio and get away with a GPU as low as a GTX 1080 Ti,  
or even an Intel A770 16G — without major issues.

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
Maybe LLMs can’t come up with great architecture, but they’re excellent at critiquing "your" code.  
The ability to discuss whether to use a provider, model, or just plain state was incredibly helpful.

#### You don't need bels and whistles! 
I'm already using this project for tasks I’d normally run through Gemini Pro.  
There’s a model on **Groq** with web search integration,  
called `compound-beta`, and it looks promising.

Don’t compete on features others already got right — you’ll have a hard time catching up.  
Implement features **you** actually need — especially the ones that are nonexistent elsewhere.

## Future Plans:

### Studio Mode

Groq has a nice feature in its developer console:  
Studio Mode, which allows easy experimentation with system prompts,  
context messages, and A/B testing of different models.

No persistence and manual copy-pasting required.  
Adding persistence in Wiydziomka will enable us  
to deliver a much better Studio Mode experience.

### Exposing Tools to Users

There is currently no user interface exposing MSPs or tools.  
This isn’t a feature that benefits the average end user,  
but power users, content creators, and domain experts  
would benefit greatly from it.

### Embeddings and RAGs

Discussion branching relies on remembering and finding past conversations to branch from.  
Maybe some vector indexing could help — suggesting to the user that certain messages from the past can be "resurrected"?

Or maybe just grouping chats would be enough?  
That could be a simpler system to operate, but it’s still a long way off.

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
