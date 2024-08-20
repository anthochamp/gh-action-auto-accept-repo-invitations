#!/usr/bin/env sh
set -eu

# https://docs.github.com/en/rest/collaborators/invitations?apiVersion=2022-11-28#list-repository-invitations-for-the-authenticated-user
getUserRepositoryInvitations() {
  origSet="$(set +o)"
  set +e
  curl -L -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $INPUT_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "$GITHUB_API_URL"/user/repository_invitations
  exitCode=$?
  eval "$origSet"

  if [ $exitCode != 0 ]; then
    echo "Error: curl ended with a non-zero exit code : $exitCode" >&2
    echo "Please match the code with the list at https://curl.se/docs/manpage.html#EXIT to find what went wrong." >&2
    exit 1
  fi
}

# https://docs.github.com/en/rest/collaborators/invitations?apiVersion=2022-11-28#accept-a-repository-invitation
acceptUserRepositoryInvitation() {
  invitationId=$1

  origSet="$(set +o)"
  set +e
  curl -L -s \
    -X PATCH \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $INPUT_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "$GITHUB_API_URL"/user/repository_invitations/"$invitationId"
  exitCode=$?
  eval "$origSet"

  if [ $exitCode != 0 ]; then
    echo "Error: curl ended with a non-zero exit code : $exitCode" >&2
    echo "Please match the code with the list at https://curl.se/docs/manpage.html#EXIT to find what went wrong." >&2
    exit 1
  fi
}

echo "Retrieving all pending invitations..."
response=$(getUserRepositoryInvitations)

if echo "$response" | jq -e 'has("status")' >/dev/null 2>&1; then
  echo "Error: GitHub API's returned the following unexpected response :" >&2
  echo "$response" >&2
  exit 1
fi

invitationsCnt=$(echo "$response" | jq 'length')

if [ "$invitationsCnt" -eq 0 ]; then
  echo "No invitation pending."
else
  echo "Found $invitationsCnt pending invitations."
fi

echo "$response" | jq '.[].id' | while read -r id; do
  repositoryFullName=$(echo "$response" | jq '.[] | select(.id == '"$id"') | .repository.full_name')
  inviterLogin=$(echo "$response" | jq '.[] | select(.id == '"$id"') | .inviter.login')
  htmlUrl=$(echo "$response" | jq '.[] | select(.id == '"$id"') | .html_url')

  echo
  echo "Accepting invitation to repository $repositoryFullName from user $inviterLogin..."
  echo "If something goes wrong, you can accept the invitation manually at $htmlUrl."

  response=$(acceptUserRepositoryInvitation "$id")

  if echo "$response" | jq -e 'has("status")' >/dev/null 2>&1; then
    echo "Error: GitHub API's returned the following unexpected response :" >&2
    echo "$response" >&2
    exit 1
  fi
done

echo "Job completed."
exit 0
