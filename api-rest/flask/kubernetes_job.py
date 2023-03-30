from kubernetes import client

JOB_NAME = "terraform-gcp"
APP_NAME = "terraform-gcp"
NAMESPACE = "infra-auto-remediate-api"

def create_job_object():
    # Configureate Pod template container
    container = client.V1Container(
        name="terraform-gcp",
        image="moto999999/terraform_gcp:latest")
        #command=["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"])
    # Create and configure a spec section
    template = client.V1PodTemplateSpec(
        metadata=client.V1ObjectMeta(labels={"app": APP_NAME}),
        spec=client.V1PodSpec(restart_policy="Never", containers=[container]))
    # Create the specification of deployment
    spec = client.V1JobSpec(
        template=template,
        backoff_limit=4)
    # Instantiate the job object
    job = client.V1Job(
        api_version="batch/v1",
        kind="Job",
        metadata=client.V1ObjectMeta(name=JOB_NAME),
        spec=spec)

    return job


def create_job(api_instance, job, logger):
    api_response = api_instance.create_namespaced_job(
        body=job,
        namespace=NAMESPACE)
    logger.info("Job created. status='%s'" % str(api_response.status))