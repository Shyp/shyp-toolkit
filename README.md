# Shyp Toolkit

The Shyp toolkit serves as home to various scripts that multiple Shyp apps use throughout the deployment pipeline

## How to work with private git dependencies

If your app uses any private git dependencies, heroku `npm install` will fail. To get around that, you would need to tap into heroku's build process so that right before `npm install` is called, you provide heroku with a private ssh key that it can use to access your repos.

Here is how you go about doing that.

### Steps
- Create a new file called `deploy-key-runner` with the following content in the `/bin` directory

```
#!/usr/bin/env bash
set -eo pipefail

prechecks() {
  local bin_directory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
  pushd "$bin_directory"
    if [ ! -f deploy-key ]; then
      curl --remote-name https://raw.githubusercontent.com/Shyp/shyp-toolkit/{release_version}/bin/deploy-key
      chmod +x deploy-key
    fi
  popd
}

main() {
  prechecks

  if [[ $1 == "setup" ]]; then
    ./bin/deploy-key setup
  else
    ./bin/deploy-key teardown
  fi
}

main "$@"
```

- In your `package.json`, add the following (This tells heroku to run the `preinstall` script before `npm install` and the `postinstall` after `npm install`)

```
"scripts": {
    "preinstall": "make deploy-key-runner setup || true",
    "postinstall": "make deploy-key-runner teardown || true"
}
```

- Create a new machine user on Github that has read access to the private repos you need.
- Create an ssh key by following these [steps] (https://help.github.com/articles/generating-an-ssh-key/)
- Save the public key to Github
- Base64 encode the private key you just generated
- Configure an environment variable for heroku to use
`heroku config:set DEPLOY_SSH_PRIVATE_KEY={BASE64_MACHINE_USER_PRIVATE_KEY} --app {APP_NAME}`

Once you deploy - you should be all setup!

## How to work with patch/minor/deploy
- In your `package.json`, add the new shyp-toolkit dependency

```npm install Shyp/shyp-toolkit#{release_version} --save-dev```

- In your `Makefile`, add the following

```
patch:
	$$(npm bin)/patch

minor:
	$$(npm bin)/minor

deploy:
	$$(npm bin)/deploy
```
