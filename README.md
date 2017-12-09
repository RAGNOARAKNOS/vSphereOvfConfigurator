# vSphereOvfConfigurator

Tool to Import, Configure and Export OVFs in/out of a VMware vSphere Environment

The tools in this repository will provde  functions to support the deployment, manipulation ane export of OVF-based vApps within a vSphere 5.x and 6.x environment.

## Pre-reqs and assumptions

* PowerCLI is installed on the machine.

* OVFtool is installed on the machine.

* This tool *MUST* support both vSphere 5.5 and 6.x, therefore any of the newer powerCLI cmdlets used must be backwards compatible.

* These tools are run from a PowerCLI instance, not a vanilla PowerShell window.

## OVF Import Tool

Takes a pre-determined list of OVF/OVA files and deploys them to the appropriate vCenter instance.

### Usage

### Inputs

2 x CSV files with the following format:-

1. Imports.csv
    1. Source OVF path and filename e.g. "C:\OVFs\Test.ova"
    1. Destination vApp name e.g. "Test"
    1. Destination datacenter name e.g. "TestDC"
        * Note that this DC value defines the credentials lookup and ultimately which vCenter the vApp is deployed to, so take care!
    1. Destination cluster name e.g. ""
    1. Destination vSphere hostname (inventory name)  e.g. "Host1.FakeDomain.com"
        * "" (blank) if using DRS to place the VM
    1. Destination datastore name e.g. "TestDatastore"
    1. Thick provisioning flag e.g. "True" / "False"
    1. Destination Network 0 name e.g. "Management Network"
        * "" if no network exists with that number
    1. Destination network 1 name (as above)
    1. Destination network 2 name (as above)
    1. Destination network 3 name (as above)
    1. Destination network 4 name (as above)
1. Credentials.csv
    1. vCenter datacenter name e.g. "TestDC"
    1. vCenter username e.g. "vSphere@administrator.local"
    1. vCenter password e.g. "P@ssw0rd"
    1. vCenter DNS (or IP address) e.g. "vCenter.FakeDomain.com" or "192.168.0.1"

### Outputs

1. vApps in the correct vCenter & powered-off

## vApp Properties Tool

Sets the vApp startup, vAPP ovf properties and resource settings en masse.

### Usage

### Inputs

### Outputs

## VM OVF Properties Tool

Sets a multitude of OVF environment runtime properties for a nummber of VMs en masse.

### Usage

### Inputs

### Outputs 

## OVF Export Tool

Exports a pre-determined list of vApps into OVFs/OVAs, and optionally deletes the source vApp.

### Usage

### Inputs

### Outputs

