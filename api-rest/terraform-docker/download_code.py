import os
import subprocess
from git import Repo
import shutil

def main():
    access_token = os.environ['GITHUB_ACCESS_TOKEN']

    repo_url = f'https://{access_token}:x-oauth-basic@github.com/moto999999/tfm.git'.replace('\n', ' ').replace(' ', '')
    repo_path = './'

    repo = Repo.init(repo_path)
    origin = repo.create_remote('origin', repo_url)
    origin.fetch()
    origin.pull(origin.refs[0].remote_head)

    # Switch to the automation branch
    repo.git.checkout('automation')

    # move the file to the destination path
    shutil.rmtree('/infra/certificates')
    shutil.rmtree('/infra/ssh_key')
    shutil.copytree('/certificates', '/infra/certificates')
    shutil.copytree('/ssh_key', '/infra/ssh_key')

    os.chdir('/infra/terraform/gcp')

    # Run the terraform commands
    subprocess.run(['terraform', 'init'])
    subprocess.run(['terraform', 'apply', '-auto-approve'])

if __name__ == '__main__':
    main()
