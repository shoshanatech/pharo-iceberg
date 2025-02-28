"
I represent a common behavior for the actions of the GithubPlugin
"
Class {
	#name : #IceGitHubAction,
	#superclass : #IceTipAction,
	#instVars : [
		'credentials',
		'remote',
		'retries'
	],
	#category : #'Iceberg-Plugin-GitHub-Commands'
}

{ #category : #testing }
IceGitHubAction class >> isAbstract [

	^ self == IceGitHubAction 
]

{ #category : #accessing }
IceGitHubAction >> credentials [ 
	^ credentials ifNil: [ credentials := self obtainCredentials ]
]

{ #category : #private }
IceGitHubAction >> defaultApplication [

	^ SpApplication defaultApplication
]

{ #category : #executing }
IceGitHubAction >> execute [
	self withErrorHandlingDo: [ 
		[[ self basicExecute ] on: IceAuthenticationError do: [ :e |
			retries = 0 ifTrue: [ e pass ].
			retries := retries - 1.
			^ self execute.
		]] on: LGitNoCredentialsProvided do: [ ^ self].
		self finishSuccess ]
]

{ #category : #private }
IceGitHubAction >> github [
	^ IceGitHubAPI new 
		credentials: self credentials;
		yourself
]

{ #category : #initialization }
IceGitHubAction >> initialize [
	retries := 3
]

{ #category : #private }
IceGitHubAction >> obtainCredentials [
	^ IceGitHubAPI obtainCredentials
]

{ #category : #accessing }
IceGitHubAction >> remote [
	^ remote
]

{ #category : #accessing }
IceGitHubAction >> remote: anObject [
	remote := anObject
]

{ #category : #private }
IceGitHubAction >> reportError: error [

	| message |
	message := error messageBody.
	message = 'Invalid field: head' ifTrue: [
		message := 'Branch does not exist on github. Please commit and push your changes.' ].
	self defaultApplication newInform
		label: message;
		title: 'Error creating pull request: ' , error messageText;
		openModal
]
