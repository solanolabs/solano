# Copyright (c) 2011-2017 Solano Labs All Rights Reserved

module SolanoConstant

  module Dependency
    VERSION_REGEXP = /([\d\.]+)/
  end

  module Default
    SLEEP_TIME_BETWEEN_POLLS = 2

    ENVIRONMENT = "production"
    SSH_FILE = "~/.ssh/id_rsa.pub"
    SUITE_TEST_PATTERN = "features/**.feature, spec/**_spec.rb, spec/features/**.feature, test/**_test.rb"
    SSH_OUTPUT_DIR = "~/.ssh/"

    GIT_SERVER = "git.solanolabs.com"
    READY_TRIES = 3
    SCM_READY_TRIES = 18
    SCM_READY_SLEEP = 10
    TEST_FINISH_TIMEOUT = 15 * 60 # 15 minutes

    PARAMS_PATH = "#{ENV['HOME']}/.solano-server"
  end

  module Config
    REMOTE_NAME = "solano"
    HG_IGNORE = ".hgignore"
    GIT_IGNORE = ".gitignore"
    CONFIG_PATHS = ["solano.yml",
                    "config/solano.yml"
                   ]
    CONFIG_PATHS_DEPRECATED = ["tddium.yml",
                               "config/tddium.yml",
                               "config/tddium.cfg"
                              ]
    EMBEDDED_SCRIPT_PATH = File.expand_path(File.join("..", "script"), __FILE__)
  end

  module Api
    module Path
      SUITES = "suites"
      SESSIONS = "sessions"
      REPORTS = "reports"
      USERS = "users"
      SIGN_IN = "#{USERS}/sign_in"
      TEST_EXECUTIONS = "test_executions"
      QUERY_TEST_EXECUTIONS = "#{TEST_EXECUTIONS}/query"
      REGISTER_TEST_EXECUTIONS = "#{TEST_EXECUTIONS}/register"
      START_TEST_EXECUTIONS = "#{TEST_EXECUTIONS}/start"
      REPO_SNAPSHOT = "repo_snapshots"
      REPORT_TEST_EXECUTIONS = "#{TEST_EXECUTIONS}/report"
      SESSION_PATCH = "session_patches"
      ACCOUNT_USAGE_BY_ACCOUNT = "accounts/usage_by_account"
      MEMBERSHIPS = "memberships"
      INSTANCES = "instances"
      KEYS = "keys"
      CONFIG = "env"
      ACCOUNTS = "accounts"
      REPOS = "repos"
    end
  end

  module License
    FILE_NAME = File.expand_path(File.join("..", "..", "..", "LICENSE.txt"), __FILE__)
  end

  module Text
    module Prompt
      module Response
        YES = "y"
        DISABLE = 'disable'
      end
      SSH_KEY = "Enter your ssh key or press 'Return'. Using '%s' by default:"
      SUITE_NAME = "Enter a repo name or press 'Return'. Using '%s' by default:"
      EMAIL = "Enter your email address: "
      CURRENT_PASSWORD = "Enter your old password: "
      PASSWORD = "Enter password: "
      NEW_PASSWORD = "Enter a new password: "
      PASSWORD_CONFIRMATION = "Confirm your password: "
      INVITATION_TOKEN = "Enter your activation token:"
      TEST_PATTERN = "Enter a pattern or press 'Return'. Using '%s' by default:"
      CI_PULL_URL = "Enter git URL to pull from (default '%s') or enter 'disable':"
      CI_PUSH_URL = "Enter git URL to push to (default '%s') or enter 'disable':"
      CAMPFIRE_ROOM = "Custom Campfire room for this suite (current: '%s') or enter 'disable':"
      HIPCHAT_ROOM = "Custom HipChat room for this suite (current: '%s') or enter 'disable':"
      ACCOUNT = "Enter the organization to create the suite under:"
      ACCOUNT_DEFAULT = "Enter the organization to create the suite under (default: '%s'):"
    end

    module Warning
      USE_PASSWORD_TOKEN = "If you signed up with Github, use token from web dashboard as password"
      HG_VERSION = "Unsupported hg version: %s"
      HG_PATHS_DEFAULT_NOT_URI = "hg paths default not a URI"
      HG_GIT_MIRROR_MISSING =<<EOF

* The hg <-> git mirror is missing.

Please run `solano hg:mirror` to create the mirror for the first time.

(Note: it may take several minutes, or even an hour, for hg:mirror to complete,
 depending on how large your repo is. Rest assured, you'll only need to run hg:mirror once.)

EOF
      GIT_VERSION_FOR_PATCH =<<EOF
Patching requires a newer version of git. Please update to git 1.8+ or contact support at support@solanolabs.com
See http://docs.solanolabs.com/RunningBuild/snapshots-and-patches/ for more info on patching
EOF
      GIT_VERSION = "Unsupported git version: %s"
      SCM_CHANGES_NOT_COMMITTED = "There are uncommitted changes in the local repository"
      SCM_UNABLE_TO_DETECT = "Unable to detect uncommitted changes"
      YAML_PARSE_FAILED = "Unable to parse %s as YAML"
      TEST_CONFIGS_MUST_BE_LIST = "The test_configs section of solano.yml must be a list of configurations"
      NO_SSH_KEY =<<EOF
You have not set an ssh key for your user.  Please add an ssh key using `solano keys:add` or visit http://ci.solanolabs.com/user_settings/ssh_keys
EOF
      SAME_SNAPSHOT_COMMIT = "Snapshot commit is the same as HEAD"
      EMPTY_PATCH = "Patch not created because it would have been empty. Most likely the commit exists in the snapshot already"
    end

    module Process
      SSH_KEY_NEEDED = "\nIt looks like you haven't authorized an SSH key to use with Solano CI.\n\n"
      DEFAULT_KEY_ADDED = "SSH key authorized."
      NO_KEYS = "No authorized keys."
      ADD_KEYS_ADD = "Adding key '%s'"
      ADD_KEYS_ADD_DONE =<<EOF
Authorized key '%s'.

Assuming your private key is in %s, you can just add the following
to ~/.ssh/config to use this new key with Solano CI:

# Solano CI SSH Config
Host %s
  IdentityFile %s
  IdentitiesOnly yes
EOF
      ADD_KEYS_GENERATE = "Generating key '%s'"
      ADD_KEYS_GENERATE_DONE =<<EOF
Generated and authorized key '%s'.

Append the following to ~/.ssh/config to use this new key with Solano CI:

# Solano CI SSH Config
Host %s
  IdentityFile %s
  IdentitiesOnly yes
EOF
      REMOVE_KEYS = "Removing key '%s'"
      REMOVE_KEYS_DONE = "Removed key '%s'"

      NO_CONFIG = "No environment variables configured."
      ADD_CONFIG = "Adding config %s=%s to %s"
      ADD_CONFIG_DONE = "Added config %s=%s to %s"
      REMOVE_CONFIG = "Removing config '%s' from %s"
      REMOVE_CONFIG_DONE = "Removed config '%s' from %s"
      CONFIG_EDIT_COMMANDS =<<EOF

Use `solano config:add <scope> <key> <value>` to set a config key.
Use `solano config:remove <scope> <key>` to remove a key.

EOF
      KEYS_EDIT_COMMANDS =<<EOF

Use `solano keys:add` to generate and authorize a new SSH keypair.
Use `solano keys:remove` to remove an authorized key from Solano CI.

Use `ssh-keygen -lf <filename>` to print fingerprint of an existing public key.

EOF
      TEST_PATTERN_INSTRUCTIONS =<<EOF

>>> Solano CI selects tests to run by default (e.g., in CI) by matching against a
    list of Ruby glob patterns.  Use "," to join multiple globs.

    You can instead specify a list of test patterns in config/solano.yml.

    Read more here: https://docs.solanolabs.com/

EOF
      NO_CONFIGURED_SUITE = "Looks like you haven't configured Solano CI on this computer for %s/%s...\n"
      FOUND_EXISTING_SUITE = "Found a suite in Solano CI for\n\n%s\n\n(on branch %s)."
      TERMINATE_INSTRUCTION = ">>> Press Ctrl-C to stop waiting.  Tests will continue running.\n"
      INTERRUPT = "Interrupted"
      SCM_PUSH = ">>> Pushing changes to Solano CI..."
      SCM_REPO_WAIT = ">>> Waiting for your repository to be prepared. Sleeping for 10 seconds..."
      STARTING_TEST = ">>> Starting Session with %s tests..."
      CHECK_TEST_STATUS = ">>> Use 'solano status' to check on pending jobs"
      FINISHED_TEST = "Finished in %s seconds"
      RUN_SOLANO_WEB = "\n>>> Run `solano web` to open the latest test results in your browser.\n"
      CHECK_TEST_REPORT = ">>> To view results, visit: %s"
      FAILED_TESTS = "Failed tests:"
      SUMMARY_STATUS = "Final result: %s."
      EXISTING_SUITE = "\nCurrent suite:\n"
      USING_EXISTING_SUITE = "Using suite '%s/%s'."
      CREATING_SUITE = "Creating suite '%s/%s'.  This will take a few seconds."
      CREATING_SUITE_CI_DISABLED = "Disabling automatic CI for this new branch."
      CREATING_REPO_SNAPSHOT = "Creating a snapshot from %s"
      CREATING_REPO_SNAPSHOT_BRANCH = "Creating a snapshot from %s, based on branch %s"
      CREATED_SUITE = "\nCreated suite.\n"
      PASSWORD_CONFIRMATION_INCORRECT = "Password confirmation incorrect"
      PASSWORD_CHANGED = "Your password has been changed."
      NEXT_STEPS = "

Next, you should register your test suite and start tests by running:

$ solano run

"
      ALREADY_LOGGED_IN = "You're already logged in"
      LOGGED_IN_SUCCESSFULLY = "Logged in successfully"
      LOGGED_OUT_SUCCESSFULLY = "Logged out successfully"
      USING_SPEC_OPTION = {:max_parallelism => "Max number of tests in parallel = %s",
                           :user_data_file => "Sending user data from %s",
                           :test_pattern => "Selecting tests that match '%s'",
                           :test_exclude_pattern => "Excluding tests that match '%s'"}
      REMEMBERED = " (Remembered value)"
      UPDATED_SUITE = "Updated suite successfully."
      UPDATED_TEST_PATTERN = "Updated test pattern to '%s'"
      UPDATED_TEST_EXCLUDE_PATTERN = "Updated test exclude pattern to '%s'"
      UPDATED_RUBY_VERSION = "Updated ruby version to '%s'"
      UPDATED_BUNDLER_VERSION = "Updated bundler version to '%s'"
      UPDATED_PYTHON_CONFIG = "Updated Python configuration:\n%s"
      UPDATED_TEST_CONFIGS = "Updated test configurations:\n%s"
      DEPENDENCY_VERSION = "... Detected %s %s"
      CONFIGURED_VERSION = "Configured %s %s from %s"
      CONFIGURED_PATTERN =<<EOF;
... Configured test pattern from %s:

%s

>>> To change the pattern:
    1. Edit %s
    2. Run `solano suite --edit` again.
EOF
      CONFIGURED_EXCLUDE_PATTERN =<<EOF;
... Configured test exclude pattern from %s:

%s

>>> To change the pattern:
    1. Edit %s
    2. Run `solano suite --edit` again.
EOF
      DETECTED_BRANCH = "... Detected branch %s"
      SETUP_CI=<<EOF;

>>> To set up Hosted CI, enter a git URL to pull from.
    You can also set a git URL to push to after tests pass.

>>> Set both pull and push URLs to 'disable' to disable hosted CI completely.

EOF
      SETUP_CAMPFIRE=<<EOF;


EOF

      ADDING_MEMBER = "Adding %s as %s..."
      ADDED_MEMBER = "Added %s"
      REMOVING_MEMBER = "Removing %s. This may take a few seconds..."
      REMOVED_MEMBER = "Removed %s"

      USING_ACCOUNT_FROM_FLAG = "Using organization '%s' (from command line)."
      USING_ACCOUNT = "Using organization '%s'."

      CONFIRM_DELETE_SUITE = <<EOF.rstrip
Are you sure you want to delete the suite %s/%s
in organization %s?
This will delete all sessions associated with this suite, and cannot be un-done.
y/[n]:
EOF
      SUITE_IN_MULTIPLE_ACCOUNTS = "The suite %s/%s exists in multiple organization:"
      SUITE_IN_MULTIPLE_ACCOUNTS_PROMPT = "Which organization do you want to delete it from:"

      ABORTING = "Aborting."
      DESCRIBE_SESSION =<<EOF

Session %s%s
Showing %s tests

EOF
      RERUN_SESSION =<<EOF

Re-run failures from a session with `solano rerun <session_id>`.
Extract details of a session with `solano describe <session_id>`.

EOF
      OPTIONS_SAVED = 'Options have been successfully saved.'
      NOT_SAVED_OPTIONS = 'There is no server information saved. Run `solano server:set`.'
      BUILD_CONTINUES = 'Session will continue running.'
      USING_PROFILE = "Starting session with profile '%s'"
      VOLUME_OVERRIDE = "Worker volume set to %s"
      USING_SESSION_MANAGER = "Starting session with manager '%s'"
      USING_CUSTOM_USER_ENV_VARS = "Starting session with custom environment variables: %s"
      SNAPSHOT_COMMIT = "Snapshot commit is %s"
      NO_SNAPSHOT = "No snapshot, creating one"
      FORCED_SNAPSHOT = "Forcing snapshot creation"
      SNAPSHOT_URL = "Snapshot url is %s"
      REQUST_PATCH_URL = "Requesting patch url"
      UPLOAD_PATCH = "Uploading patch to %s"
      USING_MASTER = "Found a branch named master, if this is not the correct default branch please run again with --force_snapshot --default_branch=master"
      ATTEMPT_UPSTREAM_PATCH = "Attempting to create a patch from %s"
      CREATING_PATCH =<<EOF
Creating a Patch by running
%s
Please see http://docs.solanolabs.com/RunningBuild/snapshots-and-patches/ for more info on patching
EOF
      ASK_FOR_SNAPSHOT =<<EOF
Since we could not create a patch, we can try creating a snapshot instead. This may take longer to upload, then a patch.
WARNING this will replace the current snapshot for the Repo.
(Please see http://docs.solanolabs.com/RunningBuild/snapshots-and-patches/ for more info)
Would you like to attempt snapshot creation?[Y/n]
EOF
    end # Process

    module Status
      SPEC_WARNINGS = "\n\n>>> Solano CI Warnings:\n\n"
      SPEC_ERRORS = "\n\n>>> Solano CI Errors:\n"
      NO_SUITE = "You currently do not have any suites"
      ALL_SUITES = "Suites:"
      CURRENT_SUITE = "Current suite: %s"
      CURRENT_SUITE_UNAVAILABLE = "Your current suite is unavailable"
      NO_ACTIVE_SESSION = "There are no running sessions for this repo."
      ACTIVE_SESSIONS = "Your active sessions for this repo%s:"
      NO_INACTIVE_SESSION = "There are no recent sessions on this branch."
      INACTIVE_SESSIONS = "Latest sessions on branch %s:"
      SESSION_DETAIL = " %10.10s %s %s in %s, %s"
      ATTRIBUTE_DETAIL = "    %s: %s"
      SEPARATOR = "====="
      USING_SUITE = "\nUsing suite:\n"
      USER_DETAILS =<<EOF;

Username: <%=user["email"]%>
User created: <%=user["created_at"]%>
EOF
      ACCOUNT_DETAILS =<<EOF;

Organization: <%=acct["account"]%>

  Role: <%=acct["account_role"]%>
  Owner: <%=acct["account_owner"]%>
  Plan: <%=acct["plan"]%>
<% if acct["trial_remaining"] && acct["trial_remaining"] > 0 %>  Trial Period Remaining: <%=acct["trial_remaining"]%> days<% end %>
<% if acct["account_url"] %>  Organization Management URL: <%=acct["account_url"]%><% end %>
<% if acct["heroku"] %>  Heroku Account Linked: <%=acct["heroku_activation_done"]%><% end %>
<% if acct["third_party_pubkey"] %>
  >>> Authorize the following SSH public key to allow Solano CI's test workers to
  install gems from private git repos or communicate via SSH to your servers:

    <%= acct["third_party_pubkey"] %>

<%end%>
EOF
      USER_THIRD_PARTY_KEY_DETAILS =<<EOF;
<% if user["third_party_pubkey"] %>
>>> Authorize the following SSH public key to allow Solano CI's test workers to
install gems from private git repos or communicate via SSH to your servers:

    <%= user["third_party_pubkey"] %>
<%end%>
EOF

      SUITE_DETAILS =<<EOF;
  Organization:         <%=suite["account"]%>
  Repo:                 <%=suite["repo_url"]%>
  Scm:                  <%=suite["scm"]%>
  Branch:               <%=suite["branch"]%>
  Default Test Pattern: <%=suite["test_pattern"]%>
  Ruby Version:         <%=suite["ruby_version"]%>
  Rubygems Version:     <%=suite["rubygems_version"]%>
  Bundler Version:      <%=suite["bundler_version"]%>
<% if suite["ci_enabled"] %>
Solano CI is enabled with the following parameters:

  Pull URL:             <%=suite["ci_pull_url"]%>

Notifications:

<%=suite["ci_notifications"]%>

<% if suite["ci_pull_url"] =~ /^git@github.com:(.*).git$/ %>
>>> Solano CI will pull from your Github repository.

    Visit https://github.com/<%= $1 %>/admin/keys
    then click "Add another deploy key" and copy and paste this key:

    <%=suite["ci_ssh_pubkey"]%>
<% else %>
>>> Authorize the following SSH key to let Solano CI's pulls and pushes through:

<%=suite["ci_ssh_pubkey"]%>
<% end %><% if suite["ci_push_url"] =~ /^git@heroku.com:(.*).git$/ %>
>>> Solano CI will push to your Heroku application <%= $1 %>.
    To authorize the key, use the following command:

    heroku keys:add <%= solano_deploy_key_file_name %> --app <%= $1 %>
<% end %><% if suite["ci_pull_url"] =~ /^git@github.com:(.*).git$/ %>
>>> Configure Github to notify Solano CI of your commits with a post-receive hook.

    Visit https://github.com/<%= $1 %>/admin/hooks#generic_minibucket
    then add the following URL and click "Update Settings":
    <%=suite["hook_uri"]%>
<% else %>
>>> In order for Solano CI to know that your repo has changed, you'll need to
    configure a post-commit hook in your Git server.

    In Unix-based Git repositories, find the repository root and look for
    a shell script in `.git/hooks/post-commit`.

    To trigger CI builds, POST to the following URL from a post-commit hook:
    <%=suite["hook_uri"]%>
<% end %>

>>> See http://docs.solanolabs.com/ for more information on Solano CI.
>>> You can enable Campfire and HipChat notifications from your Solano CI Dashboard.
<% end %>
>>> Run 'solano suite --edit' to edit these settings.
>>> Run 'solano spec' to run tests in this suite.
EOF
      ACCOUNT_MEMBERS = "Authorized users:"
      KEYS_DETAILS =<<EOF

You have authorized the following SSH public keys to communicate with Solano CI:

 Name               Fingerprint
 ------------------ ------------------------------------------------------------
EOF
      CONFIG_DETAILS =<<EOF
The following environment variables are set for this %s:

EOF
      SESSION_STATUS =<<EOF

Session Details:

 Commit: %s (%s)
 Status: %s
 Finished: %s

EOF
      SUITE_IN_MULTIPLE_ACCOUNTS = "The suite %s/%s exists in multiple organization:"
      SUITE_IN_MULTIPLE_ACCOUNTS_PROMPT = "Which organization do you want to use to get the status:"
    end

    module Error
      NOT_INITIALIZED = "Solano CI must be initialized. Try 'solano login'"
      OPTIONS_NOT_SAVED = 'Options have not been saved.'
      LIST_CONFIG_ERROR = "Error listing configuration variables"
      ADD_CONFIG_ERROR = "Error setting configuration variable"
      REMOVE_CONFIG_ERROR = "Error removing configuration variable"
      KEY_ALREADY_EXISTS = "Aborting. SSH key already exists: %s"
      KEYGEN_FAILED = "Failed to generate new SSH key for '%s'"
      LIST_API_KEY_ERROR = "Unable to retrieve API key"
      LIST_KEYS_ERROR = "Error listing SSH keys"
      REMOVE_KEYS_ERROR = "Failed to remove key '%s'"
      ADD_KEYS_DUPLICATE = "You already have a key named '%s'"
      ADD_KEY_CONTENT_DUPLICATE = "You already have a key named '%s' with the same content"
      ADD_KEYS_ERROR = "Failed to add key '%s'"
      INVALID_SSH_PUBLIC_KEY = '%s does not appear to be a valid SSH public key'
      INACCESSIBLE_SSH_PUBLIC_KEY = '%s is not accessible: %s'
      INVALID_SOLANO_FILE = ".solano.%s config file is corrupt. Try 'solano login'"
      INVALID_CONFIGURED_PATTERN =<<EOF;
Configuring test pattern from %s...

>>> The test_pattern in %s is not properly formatted.  It must be a YAML list.

You entered:

%s

>>> Edit %s and rerun `solano suite --edit`

EOF
      SCM_NOT_A_REPOSITORY = "Current working directory is not a suitable repository"
      SCM_NO_ORIGIN = "Origin URI not set; Solano CI requires origin URI to identify repository"
      SCM_REPO_NOT_READY = "Your repository is being prepped.  Try again in a minute."
      SCM_PUSH_FAILED = <<EOF;

Attempt to push source to Solano CI failed.

If you get a "Permission denied (publickey)" message, ensure that SSH is
configured to send a key you have authorized with Solano CI (Run `solano keys` to
see a list.)

For any other error, contact us at: support@solanolabs.com


EOF
      SCM_CHANGES_NOT_COMMITTED =<<EOF
There are uncommitted changes in the local repository.

Commit changes before running 'solano spec'.

Use 'solano spec --force' to test with only already-committed changes.
EOF
      SCM_NOT_FOUND = "Solano CI requires git or mercurial which are not on your PATH"
      SCM_NOT_INITIALIZED =<<EOF;
It doesn't look like you're in a git repo.  If you're not, use 'git init' to
create one.

If you are in a git repo and you're still seeing this message,
you may be using an unsupported version of git.

Please email us at support@solanolabs.com with the following trace information:

>>>>>>>>>>>>> BEGIN GIT TRACE >>>>>>>>>>>>>>>>>>>>>>>>>
hg version: #{`hg status 2> /dev/null && hg -q --version 2>&1`}
git version: #{`git status 2> /dev/null && git --version 2>&1`}
git status:  #{`git status 2> /dev/null && git status 2>&1`}
git status result: #{ $? }
git details: #{`git status 2> /dev/null && git status --porcelain 2>&1`}
git details result: #{ $? }
>>>>>>>>>>>>> END GIT TRACE   >>>>>>>>>>>>>>>>>>>>>>>>>
EOF
      NO_SESSION_EXISTS = "No session exists for the current branch. Use 'solano run'"
      NO_SUITE_EXISTS = "No suite exists for the branch '%s'. Try running 'solano suite'"
      TRY_DEFAULT_BRANCH = "Getting suites for default '%s' branch."
      NO_USER_DATA_FILE = "User data file '%s' does not exist"
      NO_MATCHING_FILES = "No files match '%s'"
      PASSWORD_ERROR = "Error changing password: %s"
      ADD_MEMBER_ERROR = "Error adding %s: %s"
      REMOVE_MEMBER_ERROR = "Error removing %s: %s"
      USE_ACTIVATE = "Visit 'https://ci.solanolabs.com' to activate your account for the first time."
      INVALID_CREDENTIALS = "Your .solano file has an invalid API key.\nRun `solano logout` and `solano login`, and then try again."
      MISSING_ACCOUNT_OPTION = "You must specify an organization by passing the --org option."
      MISSING_ACCOUNT = "You must specify an organization."
      NOT_IN_ACCOUNT = "You aren't a member of organization %s."
      CANT_FIND_SUITE = "Can't find suite for %s/%s"
      INVALID_ACCOUNT_NAME = "Invalid organization name."
      CANT_INVOKE_COMMAND =<<EOF
ERROR: could not invoke solano command
Usage: "solano COMMAND [ARGS] [OPTIONS]". For available commands, run "solano help".
EOF
      CONFIG_PATHS_COLLISION =<<EOF
You have both solano.yml and tddium.yml in your repo. We don't support merging the configuration from both of these files, so you'll have to pick one. The solano.yml file will soon be deprecated, so we recommend migrating all of your configuration to solano.yml.
EOF
      CANNOT_OVERRIDE_PROFILE="Cannot override profile for existing session"
      CANNOT_OVERRIDE_QUEUE="Cannot override queue for existing session"
      COMMAND_DEPRECATED = "This command is deprecated and will be removed in a future version"
      NO_PATCH_URL = "Failed to get Patch URL"
      SNAPSHOT_NOT_SUPPORTED =<<EOF
================================================================================================
Snapshot creation not supported
Please see http://docs.solanolabs.com/RunningBuild/snapshots-and-patches/ for more info
================================================================================================
EOF
      PATCH_NOT_SUPPORTED =<<EOF
================================================================================================
Patch creation not supported
Please see http://docs.solanolabs.com/RunningBuild/snapshots-and-patches/ for more info
================================================================================================
EOF
      PATCH_CREATION_ERROR = "Solano's current snapshot is based on commit: %s. We could not create a patch for your current state to that patch"
      DEFAULT_BRANCH =<<EOF
Could not find the default branch, looked for origin/head. We Need the default branch to create a snapshot. Please try again using --default_branch=master
Please see http://docs.solanolabs.com/RunningBuild/snapshots-and-patches/ for more info
EOF
      FAILED_TO_CREATE_SNAPSHOT =<<EOF
Could not create a repo snapshot, output from command was: %s
Please see http://docs.solanolabs.com/RunningBuild/snapshots-and-patches/ for more info
EOF
      FAILED_TO_CREATE_PATCH = "Could not create a repo patch. Tried to patch based on %s. output from command was: %s"
      ANSWER_NOT_Y =<<EOF
================================================================================================
Since you did not create a snapshot, and we could not create a patch a build can not be started.
Please see http://docs.solanolabs.com/RunningBuild/snapshots-and-patches/ for more info
================================================================================================
EOF
      NEED_TO_FORCE =<<EOF
There is currently not a Solano snapshot for this repo. We tried to create a snapshot based on your local copy of '%s', but it appears that there are unpushed commits on this branch.
To Ensure the snapshot is usable by other builds please run 'solano run' either after pushing the current commits or use 'solano run --force_snapshot' to create a snapshot from the current state.
Please see http://docs.solanolabs.com/RunningBuild/snapshots-and-patches/ for more info
EOF
    end
  end

  module DisplayedAttributes
    SUITE = %w{repo_url branch test_pattern
               ruby_version bundler_version rubygems_version
               test_scripts test_executions git_repo_uri}
    TEST_EXECUTION = %w{start_time end_time test_execution_stats report}
  end
end
