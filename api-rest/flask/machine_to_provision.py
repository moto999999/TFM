# Constants for machine types
MACHINE_STANDARD = 'standard'
MACHINE_HIGH = 'high'

# Constants for machine properties
MEMORY = 'memory'
CPU = 'cpu'

# Dictionary of available machines and their properties
machines = {
    MACHINE_STANDARD: {
        MEMORY: 8,
        CPU: 2
    },
    MACHINE_HIGH: {
        MEMORY: 16,
        CPU: 4
    }
}

@staticmethod
def get_limits_from_response(data):
    # Initialize the limits dictionary with default values of None
    limits = {"cpu": None, "memory": None}
    
    # Loop through each result in the response
    for result in data['data']['result']:
        # Get the metric data
        metric = result['metric']

        # Check if the resource type is CPU
        if metric['resource'] == 'cpu':
            # Store the CPU limit value in the limits dictionary
            limits["cpu"] = result['value'][1]
        
        # Check if the resource type is memory
        elif metric['resource'] == 'memory':
            # Store the memory limit value in the limits dictionary converted to gb
            limits["memory"] = int(result['value'][1]) / 1000 / 1000 / 1000

    # Return the limits dictionary
    return limits

@staticmethod
def machineToProvision(labels, app, requests, PROMETHEUS_URL):
    # Query Prometheus to check for app limits
    query = 'kube_pod_container_resource_requests{pod="' + labels['pod'] + '"}'
    response = requests.get(url=PROMETHEUS_URL + query)
    data = response.json()

    # Get the app limits from Prometheus response
    limits = get_limits_from_response(data)

    # Set the default machine to provision
    machine_to_provision = machines[MACHINE_STANDARD]

    # If the app has both CPU and memory limits set
    if(limits['cpu'] and limits['memory']):
        requested_cpu = float(limits['cpu'])
        requested_memory = float(limits['memory'])
        
        # If the app's limits exceed the standard machine's limits
        if (requested_cpu > machine_to_provision[CPU] or requested_memory > machine_to_provision[MEMORY]):
            # Provision the high machine instead
            machine_to_provision = machines[MACHINE_HIGH]

    # Log the machine that will be provisioned
    app.logger.info("Machine to be provisioned: " + str(machine_to_provision))

    return machine_to_provision