# Github actions self-hosted runners

See https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/quickstart-for-actions-runner-controller

How it works :

* Install the Actions Runner Controller (ARC) (gha-runner-scale-set-controller chart)
* Configure a runner scale set (gha-runner-scale-set chart)
  * set its `githubConfigUrl` to the organization or repository

The charts sources are here : https://github.com/actions/actions-runner-controller/tree/master/charts

In the workflows, use the runner scale set's helm release name, such as `runs-on: gha-runner-scale-set`.
