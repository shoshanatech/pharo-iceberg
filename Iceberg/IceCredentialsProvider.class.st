"
I am in charge of remembering credentials information, configuration and providing it as required by the different backend implementations.

I have a counter to avoid for trying for ever with the same credentials.
"
Class {
	#name : 'IceCredentialsProvider',
	#superclass : 'Object',
	#instVars : [
		'tries',
		'remote'
	],
	#classVars : [
		'ProviderType',
		'UseCustomSsh'
	],
	#category : 'Iceberg-Security',
	#package : 'Iceberg',
	#tag : 'Security'
}

{ #category : 'private' }
IceCredentialsProvider class >> defaultCredentialProviderClass [
	| providers  |
	providers := self allSubclasses.
	providers size = 1 ifTrue: [ ^ providers anyOne ].
	^ providers detect: #isDefault
]

{ #category : 'instance creation' }
IceCredentialsProvider class >> defaultForHost: aString [
	
	^ self defaultForRemote: (IceRemoteWithOnlyHostname for: aString)

]

{ #category : 'instance creation' }
IceCredentialsProvider class >> defaultForRemote: aRemote [
	^ self providerType new
		remote: aRemote;
		yourself
]

{ #category : 'instance creation' }
IceCredentialsProvider class >> defaultForRemoteUrl: url [
	^ self providerType new
		remote: (IceGitRemote url: url);
		yourself
]

{ #category : 'private' }
IceCredentialsProvider class >> isDefault [
	^ false
]

{ #category : 'private' }
IceCredentialsProvider class >> providerType [
	^ ProviderType ifNil: [ ProviderType := self defaultCredentialProviderClass ]
]

{ #category : 'private' }
IceCredentialsProvider class >> providerType: anObject [
	ProviderType := anObject
]

{ #category : 'settings' }
IceCredentialsProvider class >> settingsOn: aBuilder [
	<systemsettings>
	(aBuilder setting: #useCustomSsh)
		parent: #icebergCredentials;
		noOrdering;
		target: self;
		default: false;
		label: 'Use custom SSH keys';
		description:
			'Check if you want to have your own pair of keys (id_rsa and id_rsa.pub), without using the ssh-agent';
		with: [ (aBuilder setting: #username)
				target: self;
				targetSelector: #sshCredentials;
				label: 'SSH Username';
				default: 'git';
				description:
					'If you are trying to connect to github through ssh (something like git@github.com:owner/projectName), the username should be `git`'.
			(aBuilder setting: #publicKey)
				target: self;
				targetSelector: #sshCredentials;
				type: #FilePathEncoder;
				default: IceSshCredentials defaultPublicKey ;
				label: 'Public SSH key';
				description: 'The path to your private ssh key, probably /home/<userName>/.ssh/id_ed25519.pub or id_rsa.pub'.
			(aBuilder setting: #privateKey)
				target: self;
				targetSelector: #sshCredentials;
				type: #FilePathEncoder;
				default: IceSshCredentials defaultPrivateKey;
				label: 'Private SSH key';
				description: 'The path to your private ssh key, probably /home/<userName>/.ssh/id_ed25519 or id_rsa'.
			(aBuilder setting: #keyPassphrase)
				target: self;
				type: #Password;
				default: '';
				targetSelector: #sshCredentials;
				label: 'Passphrase of your SSH key' ]
]

{ #category : 'accessing' }
IceCredentialsProvider class >> sshCredentials [
	"It returns the default ssh credentials to use when not configured new for the host"
	^ IceCredentialStore current defaultSSHCredential 
]

{ #category : 'accessing' }
IceCredentialsProvider class >> sshCredentialsClass [
	self useCustomSsh ifTrue: [ ^ LGitCredentialsSSH ].
	^ LGitCredentialsSSHAgent
	
]

{ #category : 'accessing' }
IceCredentialsProvider class >> useCustomSsh [
	^ UseCustomSsh ifNil: [ UseCustomSsh := false ]
]

{ #category : 'accessing' }
IceCredentialsProvider class >> useCustomSsh: aBoolean [
	UseCustomSsh := aBoolean
]

{ #category : 'accessing' }
IceCredentialsProvider >> credentialStore [
	^ IceCredentialStore current
]

{ #category : 'initialization' }
IceCredentialsProvider >> initialize [
	tries := 0.

]

{ #category : 'private' }
IceCredentialsProvider >> obtainCredentials: response [
	self subclassResponsibility
]

{ #category : 'private' }
IceCredentialsProvider >> obtainPlaintextCredentials: response [
	self subclassResponsibility
]

{ #category : 'private' }
IceCredentialsProvider >> obtainSshCredentials: response [
	self subclassResponsibility
]

{ #category : 'accessing' }
IceCredentialsProvider >> plaintextCredentials [
	^ self credentialStore plaintextCredentialForHostname: remote host.
]

{ #category : 'actions' }
IceCredentialsProvider >> providePlaintextCredentials [
	^self plaintextCredentials isPresent
		ifTrue: [ self plaintextCredentials copy ]
		ifFalse: [ self providePlaintextCredentialsTo: IcePlaintextCredentials new ].
]

{ #category : 'actions' }
IceCredentialsProvider >> providePlaintextCredentialsTo: credentials [
	tries := tries + 1.

	tries >= 3 ifTrue: [ 
		Transcript show: 'aborting'; cr.
		LGitNoCredentialsProvided signal: 'There where already three failed attempts, aborting' ].
	
	tries = 1 & self plaintextCredentials isPresent
		ifTrue: [ credentials readFrom: self plaintextCredentials ]
		ifFalse: [ self obtainPlaintextCredentials: credentials ].


]

{ #category : 'actions' }
IceCredentialsProvider >> provideSshAgentCredentialsTo: credentials [
	"Just check for tries to ensure we do not enter an infinite cycle in libgit2"
	tries := tries + 1.
	tries >= 3 ifTrue: [ 
		Transcript show: 'aborting'; cr.
		LGitNoCredentialsProvided signal: 'No ssh-agent credentials found.' ]
]

{ #category : 'actions' }
IceCredentialsProvider >> provideSshCredentialsTo: credentials [
	tries := tries + 1.

	tries >= 3 ifTrue: [ 
		Transcript show: 'aborting'; cr.
		LGitNoCredentialsProvided signal: 'There where already three failed attempts, aborting' ].
		
	tries = 1 & self sshCredentials isPresent
		ifTrue: [ credentials readFrom: self sshCredentials ]
		ifFalse: [ self obtainSshCredentials: credentials ].
]

{ #category : 'accessing' }
IceCredentialsProvider >> remote: anObject [
	remote := anObject
]

{ #category : 'accessing' }
IceCredentialsProvider >> sshCredentials [
	^ IceCredentialStore current sshCredentialForHostname: remote host.
]

{ #category : 'accessing' }
IceCredentialsProvider >> sshCredentialsClass [
	^ self class sshCredentialsClass
]
