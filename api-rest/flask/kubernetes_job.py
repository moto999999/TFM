from kubernetes import client

NAMESPACE = "infra"

def create_job_object(job_name, app_name, imageToLaunch):
    # Configureate Pod template container
    container = client.V1Container(
        name=app_name,
        image=imageToLaunch,
        env=[
        client.V1EnvVar(name='GOOGLE_APPLICATION_CREDENTIALS', value='/infra/gcloud-auth-key/tfm-uc3m-sa.json'),
        client.V1EnvVar(name='GITHUB_ACCESS_TOKEN', value_from=client.V1EnvVarSource(secret_key_ref=client.V1SecretKeySelector(name='github-auth-token', key='github_token')))
        ]
    )
    # Create and configure a spec section
    template = client.V1PodTemplateSpec(
        metadata=client.V1ObjectMeta(labels={"app": app_name}),
        spec=client.V1PodSpec(restart_policy="Never", containers=[container]))
    # Create the specification of deployment
    spec = client.V1JobSpec(
        template=template,
        backoff_limit=4)
    # Instantiate the job object
    job = client.V1Job(
        api_version="batch/v1",
        kind="Job",
        metadata=client.V1ObjectMeta(name=job_name),
        spec=spec)

    return job


def create_job(api_instance, job, logger):
    api_response = api_instance.create_namespaced_job(
        body=job,
        namespace=NAMESPACE)
    logger.info("Job created. status='%s'" % str(api_response.status))