# 2023Q2-workshop - Serverless on Kubernetes

### Introduction and outline

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

### Foreign Language in the Land of Kubernetes

Kubernetes is a strange world most developers. Pronouncing some of its commonly used words only exaggerates 
the strangeness. To level set on pronunciations, explore this short [pronunciation guide](Pronunciation.md):

## The Code

This is not a workshop to teach you to code (or code better). This workshop is about creating and running serverless 
workloads in Kubernetes.

To illustrate the fundamentals, we'll use a few simple services, pre-written with the code you'll need. In the labs, 
you will change the code slightly (and with specific instructions) to exercise standard development processes:
- Coding
- Building 
- Deploying
- Running
- Observing

## The Workshop

The workshop is a series of lessons to introduce, demonstrate, and practice doing serverless in a 
Kubernetes environment.

### Lessons
A _lesson_ is a combination of theory presentation and practical lab time. The presentation lays out a few key 
aspects of the topic, but will obviously cover only a small amount of detail.

The idea is to show you a little of what's available and how it can be used, not to make you an expert at using it or 
understanding all Kubernetes, Knative, or serverless details.

The overall workshop structure will be:

### Agenda
1. Introductions
2. What is serverless
3. What is Kubernetes and K3S
4. Doing our first Kubernetes deployment (Lab 1) 
5. Knative Overview
8. Installing Knative (Lab 2)
7. Knative Functions (Lab 3)
8. Knative Eventing (lab 4)
9. Q&A and Wrap-up

> Note: Breaks are not scheduled. Take them as you need them.
