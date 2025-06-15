# Wiydziomka

Small scale LLM chating service.
Something to bridge the gap between `I'm doing everything manualy and localy`
and `IaaS inteligence as a service`.
No need for PhD in k8s and serverless cloud.
It is an entry for [T3.chat cloneathon](https://cloneathon.t3.chat/)

Hero of this project is a **[PocketBase](https://cloneathon.t3.chat/)**. Its like a firebase but in one executable.
Extend with JS/TS/GoLang you still can ship single executable.

## Installation

 - ~~Download executable from releses and double click~~... soon™
 - ~~Docker pull~~... soon™
 - ~~Flatpack/Snap/winget~~... soon™
 - ~~Wiydziomka Cloud~~... nowhere near ready. Bilings, payments, seciurity, privacy. We prefear to stay smal scale for now.
 - From sources

Ensure You have [Go language](https://go.dev/dl/)
and [Flutter](https://docs.flutter.dev/get-started/install) installed.
Clone and enter directory with terminal of Your choosing.

```shell
flutter build web
go build ./cmd/wiydziomka
```

Above will generate single executable.

## Usage & maintanance

First execution will generate OTP link to set up a superuser.
You can always upsert another superuser from console.

```shell
wiydziomka serve
wiydziomka superuser upsert EMAIL PASS
```

**Word of precaution**. Data store, named `pb_store` is generated
in ***same location as executable***, no mater of working directory.
You can use `--dev` to have verbose output and `--dir <location>`
to change store placement.

-- adding users

-- enabling providers

-- adding other models

## Room full of 🐘

Every project, especialy on tight shedule borns lots of elephants, and other quirks. Such project can give some eurekas, but let's dive into zoology matters first.

### Where support for apple?

How naive and stupid we were.
Just add some flags in github action, or `flutter build ios` right?

> You guys can just tap executable on Yout phone and run it right?

Suporting apple without having apple or someone with apple,
was one of the reasons for chosing flutter...

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
