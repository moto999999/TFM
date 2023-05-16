from flask import Flask, request
import requests

from kubernetes import client, config
import kubernetes_job

import logging
from machine_to_provision import machineToProvision
from update_terraform_code import updateWorkerNumber

import threading

app = Flask(__name__)

logging.basicConfig(level=logging.DEBUG)

# URL for Prometheus API
PROMETHEUS_URL = 'http://prometheus-operated.monitoring.svc.cluster.local:9090/api/v1/query?query='

@staticmethod
def get_labels_from_request(request):
    return request['alerts'][0]['labels']

@app.route("/api/",methods=['POST'])
def prometheus():
    """
    Handles POST requests from Prometheus, processes the alert and takes action to scale up the cluster if necessary.
    """
    json = request.get_json(force=True)
    labels = get_labels_from_request(json)

    # Check if the alert is for a unschedulable Pod
    if labels['alertname'] == 'PodUnschedulable':
        # Create a new thread and start it
        t = threading.Thread(target=podUnschedulable, args=(labels,))
        t.start()

    # Return the response data as it is
    return json

def podUnschedulable(labels):
    # Call the method to scale up the cluster
    machine_to_provision = machineToProvision(labels, app, requests, PROMETHEUS_URL)

    updateWorkerNumber()
    config.load_incluster_config()
    batch_v1 = client.BatchV1Api()

    job = kubernetes_job.create_job_object("scale-cluster-up", "terraform-gcp", "moto999999/terraform_gcp:latest")

    kubernetes_job.create_job(batch_v1, job, app.logger)