# Installing Typescript

Prerequisites: npm (from Node)

In this workshop, we will use Typescript (and optinally Java).

While CDK supports JavaScript, I prefer greater type-safety when the code I'm writing will cause the
provisioning of AWS resources. A screwy JS type conversion is one less thing I want to lose sleep over.

To install Typescript:

```shell
npm install -g typescript
```
```shell
tsc --version
```
```text
Version 5.1.3
```
