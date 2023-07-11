# Installing Node

The current [Lambda runtimes](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html) support Node v12 - v18.
We'll use Node v18 LTS in this workshop.

You can install Node directly from the [Node download page](https://nodejs.org/en/).

### NVM

Because Node versions change regularly, I recommend **nvm**, a [Node Version Manager](https://github.com/nvm-sh/nvm).
It's available for *nix OS's, so Windows users will need to use WSL. To install **nvm**, run
```shell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
```
or
```shell
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
```

Once installed, you can verify the installation with:
```shell
nvm --version
```
You'll see 0.39.3 output.
> Note: You may need to `source` your shell config file (e.g. .bash_profile or .zshrc)
> for nvm to be added to the path

Next, install and use Node 18:
```shell
nvm install 18
```
```text
Downloading and installing node v18.14.1...
Downloading https://nodejs.org/dist/v18.14.1/node-v18.14.1-darwin-x64.tar.xz...
########################################################################## 100.0%
Computing checksum with shasum -a 256
Checksums matched!
Now using node v18.14.1 (npm v7.22.0)
```

## Verify Node / npm
```shell
node --version
```
```text
v18.16.0
```
```shell
npm --version
```
```text
7.22.0
```
