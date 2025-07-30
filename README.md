# GopherCon 2025 tutorial: What story does your dependency tree tell you about your organisation?

This is the corresponding supporting details for the GopherCon 2025 tutorial, [_What story does your dependency tree tell you about your organisation?_](https://talks.jvt.me/dmd-tutorial/) by [Jamie Tanna](https://www.jvt.me).

## Scanning repos

> [!NOTE]
> If you've never logged into the GitHub Container Registry before, you'll need to follow [these instructions](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry).

For simplicity, there is a `make` task to download the scanning image, which contains prerequisites:

```sh
make -C ./container-image/scanner pull
```

It can also be manually downloaded via:

```sh
docker pull ghcr.io/deps-fyi/gophercon-uk-2025:latest
```

This image will scan given repo(s) with:

- [`renovate-graph`](https://gitlab.com/tanna.dev/renovate-graph), which uses [Renovate](https://docs.renovatebot.com/) under the hood for its [wide support of supported languages and package ecosystems](https://docs.renovatebot.com/modules/manager/)
- [`dependabot-graph`](https://gitlab.com/tanna.dev/dependabot-graph), which uses [GitHub Advanced Security's Dependency Graph](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/about-the-dependency-graph)
  - **NOTE**: if you are using this on repositories after 2025-06, please verify that the Dependency Graph is enabled on your repo. After 2025-06, it was [disabled by default](https://github.blog/changelog/2025-06-17-dependency-graph-now-defaults-to-off/).

This allows a comparison between the data that GitHub Advanced Security's Dependency Graph gets (through the [Software Bill of Materials (SBOM) endpoint](https://docs.github.com/en/rest/dependency-graph/sboms?apiVersion=2022-11-28)) vs Renovate's much more in-depth and configurable support.

### Scanning GitHub repositories

(Currently only supports GitHub.com)

For instance, if we want to run against GitHub.com, we would use:

```sh
$ env RENOVATE_TOKEN=$(gh auth token) make -C ./container-image/scanner run
# this will then interactively ask:
Enter space-separated repo slugs (i.e. oapi-codegen/oapi-codegen): oapi-codegen/oapi-codegen jamietanna-jamietanna
# ...
Finished processing, to import, run:
# I.e. if you have `dmd.db`
cd /home/jamie/workspaces/gophercon2025/tutorial && dmd import dependabot --db dmd.db out/jamietanna-jamietanna.json out/oapi-codegen-oapi-codegen.json
cd /home/jamie/workspaces/gophercon2025/tutorial && dmd import renovate --db dmd.db out/renovate-graph/github-jamietanna-jamietanna.json out/renovate-graph/github-oapi-codegen-oapi-codegen.json
```

You can also avoid interactively setting arguments by running:

```sh
$ env RENOVATE_TOKEN=$(gh auth token) make -C ./container-image/scanner run oapi-codegen/oapi-codegen
```

### Scanning GitLab repositories

(Currently only supports GitLab.com)

```sh
$ env RENOVATE_TOKEN=... RENOVATE_PLATFORM=gitlab make -C ./container-image/scanner run
# this will then interactively ask:
Enter space-separated repo slugs (i.e. oapi-codegen/oapi-codegen): tanna.dev/renovate-graph
# ...
Finished processing, to import, run:
# I.e. if you have `dmd.db`
cd /home/jamie/workspaces/gophercon2025/tutorial && dmd import renovate --db dmd.db out/renovate-graph/gitlab-tanna.dev-tz.json
```

You can also avoid interactively setting arguments by running:

```sh
$ env RENOVATE_TOKEN=... RENOVATE_PLATFORM=gitlab make -C ./container-image/scanner run tanna.dev/tz
```

### Building from source

It is also possible to build this container image from source:

```sh
# from the root of this repository
make -C ./container-image/scanner build
```

### `renovate-graph` debug logs

For ease, it is also possible to use `make ... run-debug` to get the full `renovate-graph` debug logs for a given Renovate run.
