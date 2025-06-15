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
- go to 1models1 and click **+New record**
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

### Flutter, Your dart into knee

Our team is mainly backend.
Having already experience with vibe coding,
we know that LLM just love corner themself
into architecture without good refactor strategy.

In go it is not a big problem, no harm in deperacted `ioutil`
or naked `done <-chan struct{}`. We can guide away from worst footguns.
The more deperacted and irrelevant baggage, the more cornering into halucination.

In `2 + 2 - 2 = 20` language we'll go blind.
Frameworks like react have imense baggage.
I still remember components made by class objects thingy.
Last time when I had contact with react,
graphQl was the only correct way to do api.
I even saw jQuery inside useState,
and I don't want to know in what halucination we could end up.

Event in flutter we cornered our self into inability to add routing,
but it was managable to escape without full rewrite.

Moving forward we consider Svelte or Vue or even react native if we discover how to made linux desktop from it.

### No streaming response?

Groq is fast enough that even reasoning models are almost instantionous.
For ollama, 6900xt that we have in systems is snappy enough to not complain.
Propably someone could go with Lm-Studio and use gpu as low as GTX 1080ti,
or A770 16G without problems.

### Everything throu backend?

I would like to support chromebook.
Adding MCPs, buisnes logic or agentic code would be problematic.
Provisioning apikeys to front is an interesting idea,
that we have no experience with.
One endpoint `/chat/completions` is all You need,
and virtualy all providers have it.

Having more offline capability would be nice,
but I'm not doing any substancial login in `2 + 2 - 2 = 20` language.
It is even posible to ship golang logic as wasm service worker,
and run inference on webgpu?

### Lots of elephants, but where this original one?

Why not PHP? Laravel+Inerrtia was on the table,
allegedly now experience is very good.
Last our experience with Laravel but AdminLTE was not so good.

The same we could tall about others `Why nox ...?`.
Zig, htmx, rust, alpine.js, templ.
Lots of promising and interesting options.
No time to evaluate, not willing to risk not shiping.

## Eurekas of project?

// nie potrzebujesz świecidełek które wszystkie innerozwiazania mają

// można skoncentrować się na tym co konkurencji robią źle, niż próbować ich prześcignąć w tym co robiadobrze.

// pocketbase jest mega zajebisty, kaliber pracy i funkcjonalności które dostaliśmy na starcie za free, przeogromna. szczególnie w go który jest jawny do bólu.

## Last words

We aimed for `minimal plan`, just finish even on last place is success.
In extremale case of wining any prize, we prefear to give up it to charity,
of Theo choosing.

We would like charity be involved in one of bellow.

 - Spreading knowlage
 - Digital exclusion
 - Repairability

Thank You for spending time with us.
We would love to hear more from You.
Maybe use issuses tab?
