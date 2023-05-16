import re
import os
from git import Repo
import shutil

TERRAFORM_FOLDER="./infra/terraform/gcp"

def downloadGitCode():
    access_token = os.environ['GITHUB_ACCESS_TOKEN']

    repo_url = f'https://{access_token}:x-oauth-basic@github.com/moto999999/tfm.git'.replace('\n', ' ').replace(' ', '')
    repo_path = './infra'

    repo = Repo.clone_from(repo_url, repo_path)

    # Create a new branch
    new_branch = repo.create_head('automation')

    # Check out the new branch
    new_branch.checkout()

    # Set the user name and email
    with repo.config_writer() as git_config:
        git_config.set_value('user', 'name', 'automation')
        git_config.set_value('user', 'email', 'automation@automation.com')

    return repo

def commitChanges(repo, message):
    # Stage, commit and push the changes
    repo.git.add('/app/infra')
    repo.git.commit('-m', message)
    repo.git.push('-u', 'origin', 'automation')

    # Remove code from pod
    shutil.rmtree('/app/infra')

def updateWorkerNumber():
    repo = downloadGitCode()

    # Open the file for reading
    with open(f'{TERRAFORM_FOLDER}/variables-instances.tf', 'r') as file:
        data = file.read()

    # Find the current value of the number_workers variable
    match = re.search(
        r'variable "number_workers" {[^}]*default\s*=\s*(\d+)',
        data,
        flags=re.DOTALL
    )
    current_value = int(match.group(1))
    new_value = current_value + 1

    # Update the default value of the number_workers variable
    data = re.sub(
        r'(variable "number_workers" {[^}]*default\s*=\s*)\d+',
        lambda match: f'{match.group(1)}{new_value}',
        data,
        flags=re.DOTALL
    )

    # Open the file for writing
    with open(f'{TERRAFORM_FOLDER}//variables-instances.tf', 'w') as file:
        file.write(data)

    commitChanges(repo, f'automated: Update number_workers to {new_value}')