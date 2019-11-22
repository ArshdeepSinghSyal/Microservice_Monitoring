# ZDP Monitoring

![alt text](https://zalonisvn.beanstalkapp.com/cd-zdp-monitoring/browse/git/resources/zaloni.jpg?ref=b-master)

## Project Objective

To monitor 12 ZDP microservices using Elastic's APM to monitor, use Elasticsearch to store and Kibana to visualize the collected metrics on a distributed environment over the aws cloud.

The following ZDP microservices are monitored:-

1. Gateway<br>
2. Lineage tracker<br>
3. Workflow executor<br>
4. MR executor<br>
5. Hive Connector<br>
6. Spark executor<br>
7. DME<br>
8. Ingestion warden<br>
9. Registry<br>
10. ActiveMQ<br> 
11. Elasticsearch<br>
12. Logstash<br>

## Project Architecture

![alt text](https://zalonisvn.beanstalkapp.com/cd-zdp-monitoring/browse/git/resources/architecture.png?ref=b-master)

- APM Agents are installed and configured inside the ZDP microservices.

- Metricbeat is installed on the servers running the ZDP microservices.

- APM Server, Elasticsearch and Kibana are installed and configured on the monitoring server.

- APM Agent from each microservice of the ZDP monitors that service and sends the collected data to the APM server.

- APM server collects metrics and continuously sends them to elasticsearch in real-time.

- Metricbeat collects metrics from the zdp microservices and sends it to elasticsearch.

- Elasticsearch stores metrics sent to it by APM Server.

- Kibana fetches application metrics from Elasticseach and creates the required visualizations.

## Pre-requisites

- Running ZDP on AWS on one or multiple CentOS machines.<br>
Note: This code can accomodate ZDP running on a different cloud platform and a different operating system. For that, update the following files:
    - inventory/demo/inventory.aws_ec2.yml
    - inventory/demo/hosts.yml

- Store AWS private key file in the ~/.ssh folder on localhost.
- Install & configure AWS CLI
- Dependencies:-
    - Python = 2.7
    - Ansible >= 2.6.5
    - boto
    - boto3
    - nose
    - tornado

Note: The roles can be re-used to monitor an on-prem installation of ZDP as well.

### Steps to instals dependencies

```
easy_install pip
pip install ansible==2.6.5
pip install nose
pip install tornado
pip install boto
pip install boto3
```

### AWS Prerequistes

- Create a keypair and download it from AWS EC2, you will only be able to download this keypair once.
- Move your keypair to ```~/.ssh``` folder in your localhost.
- Change permissions of the keypair to 400. As follows: chmod 400 ```~/.ssh/<keypair name>.pem```

## Running the Code

1. Clone the repo.

```
git clone https://zalonisvn.git.beanstalkapp.com/cd-zdp-monitoring.git
```

2. Go inside the directory and source the script to assume aws role (needs to be done only if you do not have admin access to your aws account.

```
source ./script.sh
```

(For details about [assuming roles](https://drive.google.com/open?id=1LwZiwtnHHbRDbk6XpkKhjLg6U1W6hUNuxjHCLfEF15c) and the [script](https://drive.google.com/file/d/1nEgEsxgpFGw6t3bioKbIWHYUXiovF1pR/view))

(The temporary credentials assigned, will time out after 1 hour of running the script. It will need to be run again after an hour)

3. Copy the inventory/example folder, and paste it inside inventory folder with a different name of your choice (Eg: demo).

4. Rename the variables in the files in inventory/demo. Update the following files:-

- inventory/demo/group_vars/all/vars.yml
- inventory/demo/inventory.aws_ec2.yml

5. Run the playbook. (It is assumed that the ZDP is already up and running)

```
ansible-playbook site-playbook.yml -i inventory/example
```
(to run it with default values)

```
ansible-playbook site-playbook.yml -i inventory/demo
```
(to run it with your updated values)

6. Restart all the ZDP microservices.

7. Visit [Visual Instance]:5601 to access Kibana to monitor the zdp.

## Project Overview

The project has 5 working ansible roles:

- Provision Visual Server (ProvisionVisualServer)
- APM Agent (APMAgent)
- APM Server (APMServer)
- Elasticsearch (Elasticsearch)
- Kibana (Kibana)
- Metricbeat (Metricbeat)
- Import Dashboard to Kibana (ImportKibanaDashboard)

### Functionality of each role:-

#### Provision Visual Server

It has the following 4 taks defined under it:-

- Create a security group with the required permisions.
- Provisions a Amazon Linux 2 machine from AWS of t2.medium tier and sets up ssh access into the machine.
- Adds the newly provisioned instance to a host group - visualserver.
- Waits for SSH to come up.

#### Elasticsearch

It has the following 8 tasks defined under it:-

- Adds Elasticsearch's gpg key.
- Adds a verified yum repository for Elasticsearch using the template elasticsearch.repo.j2.
- Installs Java 8 on the machine which is a pre-requisite to Elasticsearch.
- Uses yum package manager to install elasticsearch.
- Configures Elasticsearch by replacing configuration file elasticsearch.yml with our template file elasticsearch.yml.j2 which contains all the required configurations.
- Configures Elasticsearch by replacing configuration file jvm.options with our template file jvm.options.j2 which contains all the required configurations.
- Stop Elasticsearch.
- Starts Elasticsearch.

#### Kibana

It has the following 7 tasks defined under it:-

- Adds kibana's gpg key.
- Adds a verified yum repository for kibana using the template kibana.repo.j2.
- Uses yum package manager to install Kibana.
- Configures Kibana by replacing configuration file kibana.yml with our template file kibana.yml.j2 which contains all the required configurations.
- Stop Kibana.
- Start Kibana.

#### APM Agent

It has the following tasks defined under it:-

- Create a apm-agent directory.
- Download the APM agent.
- Add APM Agent to the zdp service file.

#### APM Server

It has the following tasks defined under it:-

- Adds APM Server's gpg key.
- Adds a verified yum repository for APM Server using the template apm-server.repo.j2.
- Uses yum package manager to install APM Server.
- Configures APM Server by replacing configuration file apm-server.yml with our template file apm-server.yml.j2 which contains all the required configurations.
- Start APM Server.

### Import Dashboard to Kibana

It is responsible for importing the JVM Memory dashboard to kibana

## Limitations

- This monitoring framework does not monitor one zdp microservice, that is Kibana. (to accomplish that changes would be required in the code of zdp's kibana)
- Some specific dropwizard metrics, such as 'Datasource Statistics' exposed by the zdp-gateway have not been visualized by this monitoring framework.