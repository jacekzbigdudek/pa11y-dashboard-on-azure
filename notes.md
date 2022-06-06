Preliminary steps for any terraform project on azure:
(1) Download and install Azure CLI tool.

(2) Log into your Azure account manually using CLI: 
    az login

(3) Set current subscription for the account you logged into: 
    az account set --subscription "<subscription-id>"
    What keeps track of this setting? Azure Resource Manager on your cloud account?

(4) Create a service principal. Pipe credential information into a file for easy reference:
    az ad sp create-for-rbac --role="Contributor" --scopes="</subscriptions/subscription-id>" > service-principal.ps1

(5) Set environment variables to hold credentials:
    Save the service principal credentials info to file as per (4)
    Then edit the file into a powershell script. Run in powershell session to set environment variables. 
    
    There are other ways of having terraform.exe (and packer?) authenticate itself, but Hashicorp recommends using environment variables to hold the service principal credentials.

(6) Write your main.tf terraform configuration file.



Some To Dos:
============
Internalize and systematize (to a reasonable extent) the process of setting up an SSH connection to VM(s) created by your IaC project.
    (a) Creating public-private key pairs.
    (b) Passing public key to IaC deployment as argument.
    (c) Setting up cloud networking components that enables SSH connections.
    (c) Storing private key on our home/work computers.

Basic "hello world" web server running on our VM on Azure.
And have it accessible via a domain name on the internet.
