# 2023Q2-workshop - Serverless on Kubernetes

July 11, 2023 5:00 pm CST, approximately 3 hours long

## Welcome!

Welcome to the second St. Louis Serverless quarterly workshop. We started this format
in 2023 to give a more in-depth look at serverless application development than what
our monthly, 1-hour meetings could provide.

No prior serverless knowledge or experience is required.

To fit into a compressed 3-hour format, the workshops will be intentionally _low-code_.
Architects, developers, and technical managers with little (recent) coding experience
can still benefit without struggling to write a bunch of code.

> Windows Users: Many of the lab instructions will include example shell commands you can use to get things done.
> Some of these will be Mac-only or *nix commands. There won't be a lot of incompatible commands.
>
> I will endeavor to explain _what_ needs to be done in addition to providing macOS commands to do it.
>
> Windows users will need to translate to Powershell or the normal command shell. Better still, if you can use WLS,
> the commands should mostly work like the Mac commands.
>
> I'm sorry for the inconvenience.

## Workshop Setup

Important: If you intend to work through the labs as I demonstrate them, you need to have the
[workshop setup](setup_instructions/workshop_setup.md) completed before the start of the workshop.

## Foreign Language in the Land of Kubernetes

Kubernetes is a strange world most developers. Pronouncing some of its commonly used words only exaggerates
the strangeness. To level set on pronunciations, explore this short [pronunciation guide](pronunciation.md):


## The Code

> A GitHub repo link will be provided for the labs at the beginning of the workshop.

This is not a workshop to teach you to code (or code better). This workshop is about creating and running serverless
workloads in Kubernetes.

To illustrate the fundamentals, each lab is in its own Markdown file, with lab steps clearly marked.

> Tip: IDEA users should open the Structure tool window when the lab markdown is open. This makes navigating to
> each step dirt very easy. Other IDEs may do the same.

## The Workshop

The workshop is a series of lessons to introduce, demonstrate, and practice doing serverless with Knative running in a
Kubernetes environment.

### Lessons

A _lesson_ is a combination of theory presentation and practical lab time. The presentation lays out a few key
aspects of the topic, but will obviously cover only a small amount of detail.

The idea is to show you a little of what's available and how it can be used, not to make you an expert at using it or
understanding all Kubernetes, Knative, or serverless details.

The overall workshop structure will be:

### Agenda
1. Introductions
2. Kubernetes + serverless with Knative
3. Kubernetes warm-up (Lab 1)
4. Installing Knative (Lab 2)
5. Knative Functions (Lab 3)
6. Knative Serving (lab 4)
7. Knative Eventing (lab 5)
8. Q&A and Wrap-up

> Note: Breaks are not scheduled. Take them as you need them.
