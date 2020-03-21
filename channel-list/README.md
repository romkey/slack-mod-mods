# channel-list

## Setup and Configuration

Make sure you have Ruby 2.6.5 available. Highly recommend [rbenv](https://github.com/rbenv/rbenv) for managing local Ruby installs.

Once you've got Ruby 2.6.5, run
```
bundle install
```
to download dependencies.

You'll need a Slack authentication token.

Go to https://api.slack.com/apps and click on "Create New App"

Choose a name like "ModMods" for the app and make sure you choose the proper Slack team as the workspace. Click "Create App".

Click "Permissions" under "Add features and functionality".

Go to "User Token Scopes" and click "Add an OAuth Scope"

Add "channels:read","channels:history" and "users:read" - these scopes permit the application to see the list of all channels, get info about the channels, and read messages from them. They do not permit the app to make any modifications to the channels or post to them.

Go back to the top of the page and click the green "Install App to Workspace" button. This will take you to a conset page; click "Allow".

You'll be taken to a page that offers you an OAuth Access Token. Copy that.

Create a file in this directory called `.env`:
```
SLACK_API_TOKEN=your-oauth-token
```

`.env` is in `.gitignore` so that it cannot be accidentally checked in to the repo.


## Usage

Run
```
bundle exec modmods.rb channels
```
to output the list of channels in text.

Use the following options:
- `--json` output as JSON
- `--csv` output as CSV
