"
Baseline for https://github.com/pharo-vcs/iceberg project
"
Class {
	#name : 'BaselineOfIceberg',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfIceberg',
	#package : 'BaselineOfIceberg'
}

{ #category : 'baseline' }
BaselineOfIceberg >> baseline: spec [
	<baseline>
	
	spec for: #common do: [ 
		spec postLoadDoIt: #postLoadWithDirective:projectSpec:.
		
		self tonel: spec.
		self libgit: spec.
		self ring2: spec.
		
		spec
			"iceberg"
			package: 'Iceberg';
			package: 'Iceberg-Plugin' with: [ spec requires: #('Iceberg' 'Iceberg-TipUI') ];
			package: 'Iceberg-Plugin-Metacello' with: [ spec requires: #('Iceberg-Plugin') ];
			package: 'Iceberg-Plugin-GitHub' with: [ spec requires: #('Iceberg-Plugin') ];
			package: 'Iceberg-Plugin-Pharo' with: [ spec requires: #('Iceberg-Plugin') ];
			package: 'Iceberg-Plugin-Migration' with: [ spec requires: #('Iceberg-Plugin') ];
			package: 'Iceberg-Metacello-Integration' with: [ spec requires: #('Iceberg')];
			package: 'Iceberg-TipUI' with: [ spec requires: #('Iceberg') ];
			package: 'Iceberg-Memory' with: [ spec requires: #('Iceberg') ];
			"tests"
			package: 'Iceberg-Tests' with: [ spec requires: #('Iceberg' 'Iceberg-Memory' 'Ring2') ];
			package: 'Iceberg-Tests-MetacelloIntegration' with: [ spec requires: #('Iceberg-Tests') ];
			package: 'Iceberg-UI-Tests' with: [ spec requires: #('Iceberg-TipUI' 'Iceberg-Tests')];
			package: 'Iceberg-Plugin-Migration-Tests' with: [ spec requires: #('Iceberg-Plugin-Migration' 'Iceberg-Tests') ];
			"libgit"
			package: 'Iceberg-Libgit' with: [ spec requires: #('Iceberg' 'LibGit') ];
			package: 'Iceberg-Libgit-Filetree' with: [ spec requires: #('Iceberg' 'Iceberg-Libgit') ];
			package: 'Iceberg-Libgit-Tonel' with: [ spec requires: #('Iceberg' 'Iceberg-Libgit' 'Tonel') ];
			"groups"
			group: 'default' with: #(
				minimal 
				'Iceberg-Metacello-Integration' 
				'Iceberg-TipUI'
				'Iceberg-Plugin' 
				'Iceberg-Plugin-Metacello'
				'Iceberg-Plugin-GitHub'
				'Iceberg-Plugin-Pharo'
				'Iceberg-Plugin-Migration');
			group: 'minimal' with: #(
				'Iceberg'
				'Iceberg-Libgit' 
				'Iceberg-Libgit-Tonel'
				'Iceberg-Libgit-Filetree');
			group: 'allTests' with: #(
				'Iceberg-Tests' 
				'Iceberg-Tests-MetacelloIntegration'
				'LibGit-Tests' 
				'Iceberg-UI-Tests'
				'Iceberg-Plugin-Migration-Tests' );
			group: 'development' with: #(default allTests) ].

]

{ #category : 'accessing' }
BaselineOfIceberg >> customProjectAttributes [
	Smalltalk os isMacOS ifTrue: [ ^ #(#MacOS) ].
	Smalltalk os isUnix ifTrue: [ ^ #(#Unix) ].
	Smalltalk os isWindows ifTrue: [ ^ #(#Windows) ]
]

{ #category : 'baseline' }
BaselineOfIceberg >> libgit: spec [
	spec 
		baseline: 'LibGit' 
		with: [ 
			spec
				repository: 'github://pharo-vcs/libgit2-pharo-bindings:v3.0.7';
  			loads: 'default' ].
	spec  
		project: 'LibGit-Tests'
		copyFrom: 'LibGit'
		with: [ spec loads: #('tests') ]
]

{ #category : 'script' }
BaselineOfIceberg >> postLoad [

	self resetKMRepository.
	(Smalltalk at: #Iceberg) bootstrap
]

{ #category : 'script' }
BaselineOfIceberg >> postLoadWithDirective: aDirective projectSpec: aSpec [
	| repository |
	self resetKMRepository.

	"Getting the repository from metacello..."
	repository := aSpec repositories list first spec createRepository.

	"We only apply the bootstrap only of the repository is a github repository.
	This is because in Iceberg's CI, the repository is cloned before and the code is loaded using filetree, so we have no commit information here..."
	(repository isKindOf: MCGitHubRepository) ifFalse: [ ^ self ].

	(Smalltalk at: #Iceberg)
		bootstrapWithCommitId: repository commitId
		packageList: aSpec packageNames
]

{ #category : 'accessing' }
BaselineOfIceberg >> projectClass [
	^ super projectClass 
	"this is breaking the bootstrap. Reverting it for now."
	"[ self class environment at: #MetacelloCypressBaselineProject ]
		on: NotFound
		do: [ super projectClass ]"
]

{ #category : 'script' }
BaselineOfIceberg >> resetKMRepository [
	Smalltalk 
		at: #KMRepository 
		ifPresent: [ :class | class reset ]
]

{ #category : 'baseline' }
BaselineOfIceberg >> ring2: spec [
	spec
		baseline: 'Ring2'
		with: [ spec repository: 'github://guillep/Ring2:v2.0.0/src' ]
]

{ #category : 'baseline' }
BaselineOfIceberg >> tonel: spec [
	spec
		baseline: 'Tonel' 
		with: [ spec repository: 'github://pharo-vcs/tonel:Pharo12' ]
]
