# Spring Application Advisor GitHub Action

This GitHub Action runs Spring Application Advisor to analyze and upgrade Spring applications.

## Local Mode (Self-Hosted Runner)

Spring Application Advisor can also be executed in **Local Mode** using a
GitHub **self-hosted runner** or directly via the Advisor CLI.

This mode is useful when:
- Running inside restricted enterprise environments
- Using GitHub Enterprise Server
- Advisor CLI is preinstalled on the runner

### Prerequisites

- Spring Application Advisor CLI available in `$PATH`
- Maven configured with Spring Enterprise repository access
- Git write access token for creating pull requests

### Example: Self-Hosted Runner Hook

Configure the following environment variable on the runner host:

```bash
ACTIONS_RUNNER_HOOK_JOB_COMPLETED=/opt/runner/advisor_script.sh


