"
I'm a command to remove branches from remotes.
"
Class {
	#name : #IceGitHubRemoveBranchesCommand,
	#superclass : #IceGitHubRemoteCommand,
	#category : #'Iceberg-Plugin-GitHub-Commands'
}

{ #category : #'accessing - defaults' }
IceGitHubRemoveBranchesCommand class >> defaultName [

	^ 'Remove Branches...'
]

{ #category : #execute }
IceGitHubRemoveBranchesCommand >> execute [

	^ IceGitHubRemoveBranchesAction new
		  repository: self repository;
		  remote: self remote;
		  executeWithContext: context
]
