# videogame-store-example-no-db-azure-devops

This Project have a full infrastructure of example based on a simple automation with three microservices based on Spring API Rest. There are no databases but just with ArrayList for an example.<br />
# Spring API Rest Microservices
<strong>UserSubscription</strong> ---> Add an existing client on a Monthly or Annual Subscription.<br />
<strong>VideoGameProducts</strong> ---> Add Videogames or Remove Existing Products<br />
<strong>VideoGameStore Final</strong> ---> Synchronize ArrayLists on UserSubscription and VideogameProducts and then, add videogame to each customer.<br />
<br />
You can import this project on your IDE and then test it.<br />
Is not required any MySQL Database or similar. This is a fake database based on Collection Framework<br />
# Automation Part
<strong>helm-integration</strong> ---> Every folder have a manifest helm dedicated to each microservices, and is able to deploy it on a cluster Kubernetes or in local instance (minikube)<br />
<strong>powershell-scripts</strong> ---> Each pipeline YAML is properly configured in a external ps1 files that calls some peculiar functions.<br />
<strong>linux-scripts (Work in progress)</strong> ---> Each pipeline YAML is properly configured in a external sh files that calls some peculiar functions.<br />
<strong>azure-pipelines-powershell</strong> ---> : Every pipeline is a yaml file with Low Language based on Azure DevOps. Most part of these tasks are based exclusively on powershell.<br />
<strong>azure-pipelines-linux (Work in progress)</strong> ---> : Every pipeline is a yaml file with Low Language based on Azure DevOps. Most part of these tasks are based exclusively on bash scripts (linux).<br />
<strong>logstash-configurations</strong> ---> Logstash is configured for each microservice, and is able to communicate with Elasticsearch.<br />
<strong>cucumber</strong> ---> Each microservice have a folder named "cucumber", dedicated to its client based on Automation Test. Each parameter is configured exclusively for Jenkins, through the paramterized build that replace every single for test the endpoint.<br />
<strong>cucumber-auto</strong> ---> Each microservice have a folder named "cucumber-auto", dedicated to its client based on Automation Test. Each microservice is properly configured with some parameters of example with Scenario's Outline.<br />
# Pipeline Videogame Store Complete Infrastructure - Before Start
File Name : <strong>azure-pipelines-powershell/videogame-store-complete-infrastructure.yaml</strong>
Required Packages to Install : <strong>Java 21, Maven, NodeJS, Helm, Minikube and Kubectl (KubernetesCli) installed.</strong><br />
This pipeline is able to build a complete infrastructure based first on Minikube, then it performs a Test Automation with Cucumber Automatically with Scenario Outline.<br />
If you want to test this code, you make sure that all parameters of authentication with its passwords including Cluster, matching with yours. Then otherwise, Pipeline will get a failure status.<br />
- <strong>Agent Configuration</strong> : You must configure an Agent on your Azure DevOps, that should have all packages mentioned before.<br />
- <strong>Credentials Part</strong> : You can configure it in <strong>Project Settings</strong> ---> <strong>Service Connections</strong> and then, configure credentials from Docker Hub.<br />
# Pipeline Videogame Store Complete Infrastructure - About
- <strong>Check Running Packages</strong> : Check if the packages in local are installed and prints the Build number with parameters inserted, and switch to minikube cluster.<br />
- <strong>Clean Previous Install</strong> : It removes previous deployment on helm, docker images and kubectl resources.<br />
- <strong>Helm Install</strong> : It creates all infrastructure resources in local through Kubernetes on Minikube.<br />
- <strong>Build and Push on Docker</strong> : Building jar file through Maven, Docker Image and Push in a Repository on Docker Hub.<br />
- <strong>Replace Images Deployment</strong> : Replaces the image already present on helm package already deployed for the new image you specified in the pipeline with its tag associated.<br />
- <strong>Test Automation</strong> : It goes to sleep for 5 minutes to be sure that all infrastructure in local, then it replaces all endpoints of minikube services generated and with Cucumber and Scenario Outlines, is able to test each parameter with endpoints setted for every single application.<br />
<br />
Enjoy!<br />
