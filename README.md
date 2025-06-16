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

In go it is not a big problem, no harm in deperacted `ioutil`
or naked `done <-chan struct{}`. We can guide away from worst footguns.
The more deperacted and irrelevant baggage, the more cornering into halucination.

Even in Flutter, we managed to corner ourselves — this time into an inability to add routing.  
But it was manageable to escape without a full rewrite.

In retrospective, our beloved to be hated language would be fine.
Maybe LLM cannot come with good arhitecture,
but can critique `Your` code all day long.

Moving forward, we’re considering Svelte, Vue, or even React Native —  
if we figure out how to make a Linux desktop build from it. 🙂

### No streaming response?

Groq is fast enough that even reasoning models are almost instantionous.
For ollama, 6900xt that we have in systems is snappy enough to not complain.
Propably someone could go with Lm-Studio and use gpu as low as GTX 1080ti,
or A770 16G without problems.

### Everything throu backend?

Provisioning apikeys to front is an interesting idea,
worth investigating further.
Maybe [goja](https://github.com/dop251/goja) to have shared logic
across backend & frontdend.

Or maybe webgpu and run inference on edge...

### Lots of elephants, but where this original one?

Why not PHP? Laravel+Inerrtia was on the table.
I heard developer experience is very good now.

The same we could tall about others `Why not ...?`.
Zig, htmx, rust, alpine.js, templ.
Lots of promising and interesting options.
No time to evaluate, not willing to risk not shiping.

## Eurekas of this project?

❤️ **[PocketBase](https://pocketbase.io/)** ❤️
Doing SPA with it was a breaze. Everything handled with minimal complexity.
Propably not good option for SSR.

Vibe critiq. Maybe LLM cannot use good architecture when writing code,
but it is very useful to critique `your` code.
Ability to discus if I should use provider, model or just _state was a godsend.

You don't need bels and whistles! I'm already using this project,
for tasks that I would normaly use gemini pro.
There is a model on **Qroq** that have web search connected,
named `compound-beta`, and it looks promising.

Don't compete on features that other get right,
You'll have hard time to catch up.
Compete on fetures that You need,
and is notexistant elsewhere.

## Future plans

### Studio mode

Groq have nice feature in developer console.
Studio mode that allows easy experimenting with system prompts,
context messages and A/B testing different models.

No persistancy and manual copy-pasting.
Having persistancy in Wiydziomka enabling us
to deliver much better studio mode.

### Exposing tools to user

There is no user interface that exposes MSPs or tools.
This is not a feature that end user would benefit from.
Power user, content creator and domain expert would benefit greatly.

### Embedings and RAGs

In perfect world, AI system would learn and grow interacting with own user.
Actualy long term memory and user context is hiden at best, not existant in most cases.

As a stop gap we can expose embeding database and rags to user.
Closest thing that exist is a coding agent that asks if can perform an action in terminal.

We humans are bad ad describing ourself.
User alergic to penats? Dislike `2 + 2 - 2 = 20` language? Don't have car?
It's posible to iteratively get system prompt good enough,
but it is hard and very manual.

We propably can use LLM itself to close the loop,
but it have to be supervised.
Preferably by te user, without introducing to much friction.

## Last words

We aimed for `minimal plan`, just finish, even on last place is success.
In extremale case of wining any prize, we prefear to give up it to charity,
of Theo choosing.

We would like charity be involved in one of bellow.

 - Spreading knowlage
 - Digital exclusion
 - Repairability

Thank You for spending time with us.
We would love to hear more from You.
Maybe use issuses tab?
