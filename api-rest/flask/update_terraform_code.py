import re
import os
from git import Repo
import shutil

FOLDER_DOWNLOAD="./infra/terraform/gcp"

def downloadGitCode():
    access_token = os.environ['GITHUB_ACCESS_TOKEN']

    repo_url = f'https://{access_token}:x-oauth-basic@github.com/moto999999/tfm.git'.replace('\n', ' ').replace(' ', '')
    repo_path = './infra'

    return Repo.clone_from(repo_url, repo_path)

def commitChanges(repo, replacement_value):
    # Stage and commit the changes
    repo.git.add('variables-instances.tf')
    repo.git.commit('-m', f'automated: Update number_workers to {replacement_value}')

    # Remove code from pod
    shutil.rmtree(FOLDER_DOWNLOAD)

def updateWorkerNumber():
    repo = downloadGitCode()

    # Open the file for reading
    with open(f'{FOLDER_DOWNLOAD}/variables-instances.tf', 'r') as file:
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
    with open(f'{FOLDER_DOWNLOAD}//variables-instances.tf', 'w') as file:
        file.write(data)

    commitChanges(repo, new_value)