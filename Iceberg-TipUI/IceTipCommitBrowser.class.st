"
I'm a browser to commit changes to a repository.

(self onRepository: IceRepository registry anyOne) openWithSpec
"
Class {
	#name : #IceTipCommitBrowser,
	#superclass : #IceTipBrowser,
	#instVars : [
		'diffPanel',
		'commentPanel',
		'saveAction'
	],
	#category : #'Iceberg-TipUI-View-Commit'
}

{ #category : #commands }
IceTipCommitBrowser class >> buildGeneralCommandGroupWith: presenter for: aCommandGroup [

	aCommandGroup register: IceTipRefreshCommitCommand forSpec
]

{ #category : #commands }
IceTipCommitBrowser class >> buildSelectionCommandGroupWith: presenter for: aCommandGroup [

	{ 	
		IceTipBrowseCommand.
		IceTipRevertChangeCommand.
	} 
	do: [ :each | aCommandGroup register: each forSpec ].
	
	aCommandGroup register: ((CmCommandGroup named: 'Edit') asSpecGroup
		beDisplayedAsGroup;
		register: IceTipTreeExpandCommand forSpec;
		register: IceTipTreeCollapseCommand forSpec;
		yourself).

]

{ #category : #'instance creation' }
IceTipCommitBrowser class >> onRepository: aRepository [

	^ self on: (IceTipRepositoryModel on: aRepository)
]

{ #category : #actions }
IceTipCommitBrowser >> accept [

	^ self doCommit
]

{ #category : #'accessing - ui' }
IceTipCommitBrowser >> commentPanel [

	^ commentPanel
]

{ #category : #'accessing - ui' }
IceTipCommitBrowser >> commentPanel: aSpPresenter [

	commentPanel := aSpPresenter
]

{ #category : #layout }
IceTipCommitBrowser >> defaultLayout [

	^ SpPanedLayout newTopToBottom
		  positionOfSlider: 66 percent;
		  add: diffPanel;
		  add: commentPanel;
		  yourself
]

{ #category : #'accessing - ui' }
IceTipCommitBrowser >> diffPanel [

	^ diffPanel
]

{ #category : #'accessing - ui' }
IceTipCommitBrowser >> diffPanel: aSpPresenter [

	diffPanel := aSpPresenter
]

{ #category : #actions }
IceTipCommitBrowser >> doCollapseSelection [

	diffPanel doCollapseSelection
]

{ #category : #actions }
IceTipCommitBrowser >> doCommit [
	| selectedItems message isPushing isSaving commitBlock|

	selectedItems := diffPanel selectedItems.
	message := commentPanel message.
	isPushing := commentPanel isPushing.
	isSaving := commentPanel isSaving.
	
	commitBlock := [  
		self
			doCommit: selectedItems
			message: message
			pushing: isPushing
			saving: isSaving ].

	(IceTipCritiquesBeforeCommitBrowser newApplication: self application model: selectedItems)
		commitModel: self model;
		onAccept: commitBlock ;
		openIfCritiques
]

{ #category : #actions }
IceTipCommitBrowser >> doCommit: aCollection message: aString pushing: pushingBoolean saving: savingBoolean [

	self model newCommitAction
		diff: self model workingCopyDiff;
		items: aCollection;
		message: aString;
		onSuccess: [ 
			self verifyNeedsRefreshOrClose.
			pushingBoolean ifTrue: [ 
				(IceTipPushAction new repository: self model entity) executeWithContext: self ].
			savingBoolean ifTrue: [ 
				saveAction execute ] ];
		executeWithContext: self
]

{ #category : #actions }
IceTipCommitBrowser >> doExpandSelection [
	
	diffPanel doExpandSelection
]

{ #category : #initialization }
IceTipCommitBrowser >> initialExtentForWindow [

	^ (800@600) scaledByDisplayScaleFactor
]

{ #category : #initialization }
IceTipCommitBrowser >> initialize [

	super initialize.
	saveAction := IceTipSaveImageAction new
]

{ #category : #initialization }
IceTipCommitBrowser >> initializeAcceptShortcut [

	self
		bindKeyCombination: $s meta
		toAction: [ self accept ].
		
	commentPanel commentText
		bindKeyCombination: $s meta
		toAction: [ self accept ].

]

{ #category : #initialization }
IceTipCommitBrowser >> initializePresenters [

	diffPanel := self instantiate: IceTipDiffSelectingPanel on: self model workingCopyDiff.
	diffPanel leftLabel: 'Repository'.
	diffPanel rightLabel: 'Working Copy'.
	
	commentPanel := self instantiate: IceTipCommentPanel on: self model.
	commentPanel onCommit: [ self doCommit ].
	
	self initializeAcceptShortcut
]

{ #category : #initialization }
IceTipCommitBrowser >> initializeWindow: aWindow [

	super initializeWindow: aWindow.
	aWindow bindKeyCombination: $s meta toAction: [ self accept ]
]

{ #category : #'accessing - ui' }
IceTipCommitBrowser >> mainList [
	"Answer the presenter that is the main list of items of this browser."

	^ diffPanel iceNodesTree
]

{ #category : #accessing }
IceTipCommitBrowser >> refresh [

	diffPanel refresh
]

{ #category : #private }
IceTipCommitBrowser >> refreshWhenRepository: ann [

	(self model isModelOf: ann repository)
		ifFalse: [ ^ self ].
	self model reset.
	self refresh
]

{ #category : #accessing }
IceTipCommitBrowser >> saveAction: anAction [

	saveAction := anAction
]

{ #category : #initialization }
IceTipCommitBrowser >> subscribeToAnnouncements [

	self announcer
		when: IceTipDiffRefreshed
		send: #refreshWhenRepository:
		to: self
]

{ #category : #initialization }
IceTipCommitBrowser >> titleForWindow [

	^ 'Commit on {1} branch {2}' format: { 
			  self model name.
			  self model branchName }
]

{ #category : #private }
IceTipCommitBrowser >> verifyNeedsRefreshOrClose [
	"Verifies if there are remaining changes to commit. 
	 In case there are none, close the window."
	
	self model reset.
	diffPanel model reset.
	diffPanel model isEmpty
		ifTrue: [ ^ self closeWindow ].
	self commentPanel clear. 
	diffPanel basicRefresh
]
