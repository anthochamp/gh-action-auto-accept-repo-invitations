# GitHub Action to automatically accept collaboration invitations to GitHub repositories

![GitHub License](https://img.shields.io/github/license/anthochamp/gh-action-auto-accept-repo-invitations?style=for-the-badge)

![GitHub Release](https://img.shields.io/github/v/release/anthochamp/gh-action-auto-accept-repo-invitations?style=for-the-badge&color=457EC4)
![GitHub Release Date](https://img.shields.io/github/release-date/anthochamp/gh-action-auto-accept-repo-invitations?style=for-the-badge&display_date=published_at&color=457EC4)

## Setup

Create a new workflow in your user's repository (where you put your beautiful GitHub's profile README.md) :

```yaml
name: Auto accept collaboration invitations

on:
  schedule:
    - cron: 0 0 * * *

jobs:
  accept:
    runs-on: ubuntu-latest
    steps:
      - uses: anthochamp/gh-action-auto-accept-repo-invitations@v1.0.2
        with:
          TOKEN: ${{ secrets.TOKEN }}
```

Use a tool like [crontab Guru](https://crontab.guru/) to generate a cron scheduling string.

## Parameters

| Variable | Description |
| - | - |
| TOKEN | **REQUIRED**<br>A PAT with repo privileges. |

## Known issues

- It should work with a fined-grained PAT with repositories administration R+W privileges but for some reason it does not.
