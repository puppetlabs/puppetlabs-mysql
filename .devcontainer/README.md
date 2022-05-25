# devcontainer


For format details, see https://aka.ms/devcontainer.json. 

For config options, see the README at:
https://github.com/microsoft/vscode-dev-containers/tree/v0.140.1/containers/puppet
 
``` json
{
	"name": "Puppet Development Kit (Community)",
	"dockerFile": "Dockerfile",

	// Set *default* container specific settings.json values on container create.
	"settings": {
		"terminal.integrated.shell.linux": "/bin/bash"
	},

	// Add the IDs of extensions you want installed when the container is created.
	"extensions": [
		"puppet.puppet-vscode",
		"rebornix.Ruby"
	]

	// Use 'forwardPorts' to make a list of ports inside the container available locally.
	"forwardPorts": [],

	// Use 'postCreateCommand' to run commands after the container is created.
	"postCreateCommand": "pdk --version",
}
```



