# nexus_bootstrap

Welcome to your new module. A short overview of the generated parts can be found in the PDK documentation at https://puppet.com/pdk/latest/pdk_generating_modules.html .

The README template below provides a starting point with details about what information to include in your README.

#### Table of Contents

1. [Description](#description)
2. [Setup](#setup)
3. [Usage](#usage)

## Description

This is simply a Bolt task to bootstrap a Nexus OSS installation with an internal Chocolatey repository.

## Setup

* Chocolatey should already be installed on the system, as it will be leveraged by the task.

## Usage

    Run it insecurely over WinRM with the Administrator account:

    bolt task run nexus_bootstrap::configure -t myserver.contoso.com --transport winrm --no-ssl --user Administrator --password meepzorp

Output will have a bunch of chocolatey messaging, then a hash of the following:
  
    {
        "password":  "422d3d65-539b-4e1d-8222-3bb29faddfc",
        "apikey":  "d4f440a7-d454-34aa-9e8b-a56dc9f1bb8d"
    }

  You can then connect to http://myserver.contoso.com:8081 with the username `admin` and password above. To push choco packages, supply the api key above.

  Note: This is solely for use in POC lab environments. One would logically assume things like security and better planning before using it in production. If you are that logical person, I would gladly accept your pull requests.